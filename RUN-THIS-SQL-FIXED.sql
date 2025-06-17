-- COPY AND PASTE THIS ENTIRE FILE INTO SUPABASE SQL EDITOR
-- Fixed version for Supabase

-- Drop types if they exist (ignore errors if they don't)
DROP TYPE IF EXISTS grocery_category CASCADE;
DROP TYPE IF EXISTS task_status CASCADE;
DROP TYPE IF EXISTS task_priority CASCADE;
DROP TYPE IF EXISTS event_type CASCADE;

-- Create custom types
CREATE TYPE grocery_category AS ENUM (
  'produce', 'dairy', 'meat', 'pantry', 'household', 'other'
);

CREATE TYPE task_status AS ENUM (
  'pending', 'in_progress', 'completed', 'cancelled'
);

CREATE TYPE task_priority AS ENUM (
  'low', 'medium', 'high', 'urgent'
);

CREATE TYPE event_type AS ENUM (
  'appointment', 'meeting', 'reminder', 'birthday', 'holiday', 'other'
);

-- Create main tables
CREATE TABLE family_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT,
  avatar_url TEXT,
  color TEXT DEFAULT '#007AFF',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  status task_status DEFAULT 'pending',
  priority task_priority DEFAULT 'medium',
  due_date TIMESTAMPTZ,
  time_group TEXT CHECK (time_group IN ('morning', 'afternoon', 'evening')),
  list_type TEXT DEFAULT 'inbox' CHECK (list_type IN ('inbox', 'today', 'upcoming', 'anytime', 'someday')),
  created_by UUID REFERENCES family_members(id) ON DELETE SET NULL,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE task_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  family_member_id UUID REFERENCES family_members(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(task_id, family_member_id)
);

CREATE TABLE grocery_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  quantity DECIMAL,
  unit TEXT,
  category grocery_category DEFAULT 'other',
  notes TEXT,
  is_purchased BOOLEAN DEFAULT false,
  always_buy BOOLEAN DEFAULT false,
  last_bought TIMESTAMPTZ,
  added_by UUID REFERENCES family_members(id) ON DELETE SET NULL,
  purchased_by UUID REFERENCES family_members(id) ON DELETE SET NULL,
  list_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE calendar_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  event_type event_type DEFAULT 'appointment',
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  all_day BOOLEAN DEFAULT false,
  location TEXT,
  recurring_config JSONB,
  created_by UUID REFERENCES family_members(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (end_time > start_time)
);

CREATE TABLE event_attendees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES calendar_events(id) ON DELETE CASCADE,
  family_member_id UUID REFERENCES family_members(id) ON DELETE CASCADE,
  rsvp_status TEXT DEFAULT 'pending' CHECK (rsvp_status IN ('pending', 'accepted', 'declined', 'tentative')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, family_member_id)
);

-- Create additional helper tables
CREATE TABLE grocery_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  created_by UUID REFERENCES family_members(id) ON DELETE SET NULL,
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE grocery_template_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID REFERENCES grocery_templates(id) ON DELETE CASCADE,
  grocery_item_id UUID REFERENCES grocery_items(id) ON DELETE CASCADE,
  UNIQUE(template_id, grocery_item_id)
);

-- Create indexes for performance
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_list_type ON tasks(list_type);
CREATE INDEX idx_grocery_items_category ON grocery_items(category);
CREATE INDEX idx_calendar_events_start_time ON calendar_events(start_time);

-- Enable Row Level Security
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE grocery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE grocery_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE grocery_template_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_attendees ENABLE ROW LEVEL SECURITY;

-- Create basic RLS policies (all authenticated users can see/modify for now)
CREATE POLICY "Enable read for all users" ON family_members
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable insert for authenticated users" ON family_members
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable update for own record" ON family_members
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Enable all for authenticated users" ON tasks
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users" ON task_assignments
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users" ON grocery_items
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users" ON grocery_templates
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users" ON grocery_template_items
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users" ON calendar_events
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users" ON event_attendees
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Create update trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers
CREATE TRIGGER update_family_members_updated_at BEFORE UPDATE ON family_members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_grocery_items_updated_at BEFORE UPDATE ON grocery_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_grocery_templates_updated_at BEFORE UPDATE ON grocery_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_calendar_events_updated_at BEFORE UPDATE ON calendar_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create helpful views
CREATE VIEW tasks_with_assignees AS
SELECT 
  t.*,
  COALESCE(
    json_agg(
      json_build_object(
        'id', fm.id,
        'name', fm.name,
        'color', fm.color
      )
    ) FILTER (WHERE fm.id IS NOT NULL),
    '[]'::json
  ) as assignees
FROM tasks t
LEFT JOIN task_assignments ta ON t.id = ta.task_id
LEFT JOIN family_members fm ON ta.family_member_id = fm.id
GROUP BY t.id;

CREATE VIEW events_with_attendees AS
SELECT 
  e.*,
  COALESCE(
    json_agg(
      json_build_object(
        'id', fm.id,
        'name', fm.name,
        'color', fm.color,
        'rsvp_status', ea.rsvp_status
      )
    ) FILTER (WHERE fm.id IS NOT NULL),
    '[]'::json
  ) as attendees
FROM calendar_events e
LEFT JOIN event_attendees ea ON e.id = ea.event_id
LEFT JOIN family_members fm ON ea.family_member_id = fm.id
GROUP BY e.id;

-- Verify the setup
SELECT 'Setup complete! Tables created: ' || count(*)::text || ' tables' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('family_members', 'tasks', 'task_assignments', 'grocery_items', 'grocery_templates', 'calendar_events', 'event_attendees');