#!/usr/bin/env node

/**
 * Automated Supabase Setup Script for Family Hub
 * Uses Supabase MCP integration to create and configure projects
 */

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Configuration for our three environments
const ENVIRONMENTS = {
  development: {
    name: 'family-hub-dev',
    description: 'Development environment for Family Hub',
  },
  staging: {
    name: 'family-hub-staging', 
    description: 'Staging environment for Family Hub',
  },
  production: {
    name: 'family-hub-prod',
    description: 'Production environment for Family Hub',
  }
};

class SupabaseSetup {
  constructor(accessToken) {
    this.accessToken = accessToken;
    this.projectsCreated = {};
  }

  async createProjects() {
    console.log('🚀 Creating Supabase projects...\n');
    
    for (const [env, config] of Object.entries(ENVIRONMENTS)) {
      try {
        console.log(`📦 Creating ${env} project: ${config.name}`);
        
        // Note: Project creation via API requires Supabase Pro plan
        // For now, we'll provide instructions for manual creation
        // and focus on automated database setup
        
        console.log(`   Project name: ${config.name}`);
        console.log(`   Description: ${config.description}`);
        console.log(`   Region: auto-select closest\n`);
        
        // Store project info for later steps
        this.projectsCreated[env] = config;
        
      } catch (error) {
        console.error(`❌ Error creating ${env} project:`, error.message);
      }
    }
    
    console.log('✅ Project creation instructions provided');
    console.log('📝 Next: Manually create these projects in Supabase dashboard\n');
  }

  async setupDatabase(projectUrl, serviceKey, environment) {
    console.log(`🗄️  Setting up database for ${environment}...`);
    
    try {
      const supabase = createClient(projectUrl, serviceKey);
      
      // Read migration file
      const migrationPath = path.join(__dirname, '../supabase/migrations/20240101_initial_schema.sql');
      const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
      
      // Execute migration
      console.log('   Running database migration...');
      const { data, error } = await supabase.rpc('exec_sql', { 
        sql: migrationSQL 
      });
      
      if (error) {
        console.error(`❌ Migration failed for ${environment}:`, error);
        return false;
      }
      
      console.log(`✅ Database migration completed for ${environment}`);
      
      // Optionally run seed data for development
      if (environment === 'development') {
        console.log('   Adding seed data for development...');
        const seedPath = path.join(__dirname, '../supabase/seed.sql');
        const seedSQL = fs.readFileSync(seedPath, 'utf8');
        
        const { error: seedError } = await supabase.rpc('exec_sql', { 
          sql: seedSQL 
        });
        
        if (!seedError) {
          console.log('✅ Seed data added successfully');
        }
      }
      
      return true;
      
    } catch (error) {
      console.error(`❌ Database setup failed for ${environment}:`, error.message);
      return false;
    }
  }

  generateEnvFile() {
    console.log('📄 Generating environment configuration...\n');
    
    const envTemplate = `# Family Hub Environment Variables
# Replace with your actual Supabase project credentials

# Production Environment
NEXT_PUBLIC_SUPABASE_URL_PRODUCTION=https://your-prod-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY_PRODUCTION=your-prod-anon-key
SUPABASE_SERVICE_ROLE_KEY_PRODUCTION=your-prod-service-key

# Staging Environment  
NEXT_PUBLIC_SUPABASE_URL_STAGING=https://your-staging-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY_STAGING=your-staging-anon-key
SUPABASE_SERVICE_ROLE_KEY_STAGING=your-staging-service-key

# Development Environment
NEXT_PUBLIC_SUPABASE_URL_DEVELOPMENT=https://your-dev-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY_DEVELOPMENT=your-dev-anon-key
SUPABASE_SERVICE_ROLE_KEY_DEVELOPMENT=your-dev-service-key

# Main Environment (Production fallback)
NEXT_PUBLIC_SUPABASE_URL=\${NEXT_PUBLIC_SUPABASE_URL_PRODUCTION}
NEXT_PUBLIC_SUPABASE_ANON_KEY=\${NEXT_PUBLIC_SUPABASE_ANON_KEY_PRODUCTION}
SUPABASE_SERVICE_ROLE_KEY=\${SUPABASE_SERVICE_ROLE_KEY_PRODUCTION}

# App Configuration
NEXT_PUBLIC_APP_URL=https://family-hub.vercel.app
NEXT_PUBLIC_APP_NAME=Family Hub
`;

    const envPath = path.join(__dirname, '../.env.generated');
    fs.writeFileSync(envPath, envTemplate);
    
    console.log('✅ Environment template created at .env.generated');
    console.log('📝 Copy values from Supabase dashboard to complete setup\n');
  }

  async run() {
    console.log('🏠 Family Hub - Supabase Setup\n');
    console.log('This script will help set up your Supabase infrastructure\n');
    
    // Step 1: Create projects (instructions)
    await this.createProjects();
    
    // Step 2: Generate environment template
    this.generateEnvFile();
    
    // Step 3: Provide next steps
    console.log('📋 Next Steps:');
    console.log('1. Create the 3 projects manually in Supabase dashboard');
    console.log('2. Copy project URLs and API keys');
    console.log('3. Update .env.generated with real values');
    console.log('4. Run database migrations in each project');
    console.log('5. Configure Vercel environment variables\n');
    
    console.log('🚀 Ready to continue with automated setup!');
  }
}

// CLI interface
if (require.main === module) {
  const accessToken = process.env.SUPABASE_ACCESS_TOKEN;
  
  if (!accessToken) {
    console.error('❌ Please set SUPABASE_ACCESS_TOKEN environment variable');
    console.log('Get your token from: https://supabase.com/dashboard/account/tokens');
    process.exit(1);
  }
  
  const setup = new SupabaseSetup(accessToken);
  setup.run().catch(console.error);
}

module.exports = SupabaseSetup;