-- COPY AND PASTE THIS ENTIRE FILE INTO SUPABASE SQL EDITOR
-- This is the complete schema for Family Hub

-- Create custom types first
CREATE TYPE IF NOT EXISTS grocery_category AS ENUM (
  'produce', 'dairy', 'meat', 'pantry', 'household', 'other'
);

CREATE TYPE IF NOT EXISTS task_status AS ENUM (
  'pending', 'in_progress', 'completed', 'cancelled'
);

CREATE TYPE IF NOT EXISTS task_priority AS ENUM (
  'low', 'medium', 'high', 'urgent'
);

CREATE TYPE IF NOT EXISTS event_type AS ENUM (
  'appointment', 'meeting', 'reminder', 'birthday', 'holiday', 'other'
);

-- Create main tables
CREATE TABLE IF NOT EXISTS family_members (
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

CREATE TABLE IF NOT EXISTS tasks (
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

CREATE TABLE IF NOT EXISTS task_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  family_member_id UUID REFERENCES family_members(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(task_id, family_member_id)
);

CREATE TABLE IF NOT EXISTS grocery_items (
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

CREATE TABLE IF NOT EXISTS calendar_events (
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

CREATE TABLE IF NOT EXISTS event_attendees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES calendar_events(id) ON DELETE CASCADE,
  family_member_id UUID REFERENCES family_members(id) ON DELETE CASCADE,
  rsvp_status TEXT DEFAULT 'pending' CHECK (rsvp_status IN ('pending', 'accepted', 'declined', 'tentative')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, family_member_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_list_type ON tasks(list_type);
CREATE INDEX IF NOT EXISTS idx_grocery_items_category ON grocery_items(category);
CREATE INDEX IF NOT EXISTS idx_calendar_events_start_time ON calendar_events(start_time);

-- Enable Row Level Security
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE grocery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_attendees ENABLE ROW LEVEL SECURITY;

-- Create basic RLS policies (all authenticated users can see/modify for now)
CREATE POLICY "Enable all for authenticated users" ON family_members
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users" ON tasks
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users" ON task_assignments
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users" ON grocery_items
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

CREATE TRIGGER update_calendar_events_updated_at BEFORE UPDATE ON calendar_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Verify the setup
SELECT 'Setup complete! Tables created: ' || count(*)::text || ' tables' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('family_members', 'tasks', 'task_assignments', 'grocery_items', 'calendar_events', 'event_attendees');