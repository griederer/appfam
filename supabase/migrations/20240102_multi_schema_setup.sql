-- Family Hub Multi-Schema Setup for Cost-Optimized Single Project
-- This creates separate schemas for different environments while using a single Supabase project

-- Create schemas for different environments
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dev;

-- Grant permissions to authenticated users
GRANT USAGE ON SCHEMA staging TO authenticated;
GRANT USAGE ON SCHEMA dev TO authenticated;
GRANT CREATE ON SCHEMA staging TO authenticated;
GRANT CREATE ON SCHEMA dev TO authenticated;

-- Function to duplicate schema structure
CREATE OR REPLACE FUNCTION duplicate_schema_structure(source_schema text, target_schema text)
RETURNS void AS $$
DECLARE
    object_record record;
    target_table text;
BEGIN
    -- Create tables in target schema
    FOR object_record IN 
        SELECT 
            table_name,
            'CREATE TABLE ' || target_schema || '.' || table_name || ' (LIKE ' || source_schema || '.' || table_name || ' INCLUDING ALL)' as create_statement
        FROM information_schema.tables 
        WHERE table_schema = source_schema 
        AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE object_record.create_statement;
    END LOOP;

    -- Copy foreign key constraints
    FOR object_record IN
        SELECT
            'ALTER TABLE ' || target_schema || '.' || tc.table_name || 
            ' ADD CONSTRAINT ' || tc.constraint_name || '_' || target_schema ||
            ' FOREIGN KEY (' || kcu.column_name || ')' ||
            ' REFERENCES ' || target_schema || '.' || ccu.table_name || '(' || ccu.column_name || ')' ||
            ' ON DELETE ' || rc.delete_rule ||
            ' ON UPDATE ' || rc.update_rule as create_statement
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
        JOIN information_schema.referential_constraints rc ON rc.constraint_name = tc.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY' 
        AND tc.table_schema = source_schema
    LOOP
        BEGIN
            EXECUTE object_record.create_statement;
        EXCEPTION WHEN others THEN
            -- Skip if constraint already exists
            NULL;
        END;
    END LOOP;

    -- Copy indexes
    FOR object_record IN
        SELECT 
            'CREATE INDEX IF NOT EXISTS ' || i.indexname || '_' || target_schema || 
            ' ON ' || target_schema || '.' || i.tablename || 
            ' USING ' || i.indexdef as create_statement
        FROM pg_indexes i
        WHERE i.schemaname = source_schema
        AND i.indexname NOT LIKE '%_pkey'
        AND i.indexname NOT LIKE '%_key'
    LOOP
        BEGIN
            EXECUTE regexp_replace(
                object_record.create_statement, 
                ' USING .*', 
                substring(object_record.create_statement from ' USING .*')
            );
        EXCEPTION WHEN others THEN
            -- Skip if index already exists
            NULL;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Duplicate public schema to staging and dev
SELECT duplicate_schema_structure('public', 'staging');
SELECT duplicate_schema_structure('public', 'dev');

-- Create environment detection function
CREATE OR REPLACE FUNCTION get_current_schema()
RETURNS text AS $$
DECLARE
    app_env text;
BEGIN
    -- Get environment from app context (set by application)
    app_env := current_setting('app.environment', true);
    
    IF app_env = 'production' OR app_env IS NULL THEN
        RETURN 'public';
    ELSIF app_env = 'staging' THEN
        RETURN 'staging';
    ELSIF app_env = 'development' THEN
        RETURN 'dev';
    ELSE
        RETURN 'public';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create views in public schema that route to appropriate schema based on environment
CREATE OR REPLACE VIEW current_tasks AS
SELECT * FROM public.tasks
UNION ALL
SELECT * FROM staging.tasks WHERE get_current_schema() = 'staging'
UNION ALL
SELECT * FROM dev.tasks WHERE get_current_schema() = 'dev';

-- RLS Policies for multi-schema setup
CREATE POLICY "Schema isolation for tasks" ON public.tasks
    FOR ALL USING (
        get_current_schema() = 'public'
    );

CREATE POLICY "Schema isolation for tasks staging" ON staging.tasks
    FOR ALL USING (
        get_current_schema() = 'staging'
    );

CREATE POLICY "Schema isolation for tasks dev" ON dev.tasks
    FOR ALL USING (
        get_current_schema() = 'dev'
    );

-- Create a function to set environment for connection
CREATE OR REPLACE FUNCTION set_app_environment(env text)
RETURNS void AS $$
BEGIN
    PERFORM set_config('app.environment', env, false);
END;
$$ LANGUAGE plpgsql;

-- Create helper function to clear test data
CREATE OR REPLACE FUNCTION clear_test_data(schema_name text)
RETURNS void AS $$
DECLARE
    table_record record;
BEGIN
    IF schema_name NOT IN ('staging', 'dev') THEN
        RAISE EXCEPTION 'Can only clear staging or dev schemas';
    END IF;
    
    -- Disable triggers temporarily
    SET session_replication_role = 'replica';
    
    -- Truncate all tables in the schema
    FOR table_record IN
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = schema_name
    LOOP
        EXECUTE 'TRUNCATE TABLE ' || schema_name || '.' || table_record.tablename || ' CASCADE';
    END LOOP;
    
    -- Re-enable triggers
    SET session_replication_role = 'origin';
END;
$$ LANGUAGE plpgsql;

-- Add comments for documentation
COMMENT ON SCHEMA staging IS 'Schema for preview deployments and staging tests';
COMMENT ON SCHEMA dev IS 'Schema for local development and testing';
COMMENT ON FUNCTION get_current_schema() IS 'Returns the appropriate schema based on environment setting';
COMMENT ON FUNCTION set_app_environment(text) IS 'Sets the environment context for the current session';
COMMENT ON FUNCTION clear_test_data(text) IS 'Clears all data from test schemas (staging/dev only)';

-- Create environment indicator table
CREATE TABLE IF NOT EXISTS public.environment_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    environment TEXT NOT NULL,
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(environment)
);

-- Insert environment configurations
INSERT INTO public.environment_config (environment, is_active) VALUES
    ('production', true),
    ('staging', false),
    ('development', false)
ON CONFLICT (environment) DO NOTHING;

-- Grant permissions
GRANT ALL ON ALL TABLES IN SCHEMA staging TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA staging TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA dev TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA dev TO authenticated;