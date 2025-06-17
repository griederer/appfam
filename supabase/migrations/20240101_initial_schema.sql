-- Family Hub Initial Database Schema
-- Create custom types first

-- Enums for various categories and statuses
CREATE TYPE grocery_category AS ENUM (
  'produce',
  'dairy',
  'meat',
  'pantry',
  'household',
  'other'
);

CREATE TYPE task_status AS ENUM (
  'pending',
  'in_progress',
  'completed',
  'cancelled'
);

CREATE TYPE task_priority AS ENUM (
  'low',
  'medium',
  'high',
  'urgent'
);

CREATE TYPE event_type AS ENUM (
  'appointment',
  'meeting',
  'reminder',
  'birthday',
  'holiday',
  'other'
);

-- Core Tables

-- Family Members table (links to Supabase auth.users)
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
  
  -- Ensure one family member per user
  UNIQUE(user_id)
);

-- Tasks table
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

-- Task assignments (many-to-many relationship)
CREATE TABLE task_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  family_member_id UUID REFERENCES family_members(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Prevent duplicate assignments
  UNIQUE(task_id, family_member_id)
);

-- Grocery items table
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
  list_id UUID, -- For grouping items into lists
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Grocery templates for reusable lists
CREATE TABLE grocery_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  created_by UUID REFERENCES family_members(id) ON DELETE SET NULL,
  is_public BOOLEAN DEFAULT true, -- Visible to all family members
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Template items (many-to-many)
CREATE TABLE grocery_template_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID REFERENCES grocery_templates(id) ON DELETE CASCADE,
  grocery_item_id UUID REFERENCES grocery_items(id) ON DELETE CASCADE,
  
  UNIQUE(template_id, grocery_item_id)
);

-- Calendar events table
CREATE TABLE calendar_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  event_type event_type DEFAULT 'appointment',
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  all_day BOOLEAN DEFAULT false,
  location TEXT,
  recurring_config JSONB, -- Store recurring event configuration
  created_by UUID REFERENCES family_members(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Ensure end time is after start time
  CHECK (end_time > start_time)
);

-- Event attendees (many-to-many relationship)
CREATE TABLE event_attendees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES calendar_events(id) ON DELETE CASCADE,
  family_member_id UUID REFERENCES family_members(id) ON DELETE CASCADE,
  rsvp_status TEXT DEFAULT 'pending' CHECK (rsvp_status IN ('pending', 'accepted', 'declined', 'tentative')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Prevent duplicate attendees
  UNIQUE(event_id, family_member_id)
);

-- Indexes for performance
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_list_type ON tasks(list_type);
CREATE INDEX idx_tasks_created_by ON tasks(created_by);

CREATE INDEX idx_task_assignments_task_id ON task_assignments(task_id);
CREATE INDEX idx_task_assignments_family_member_id ON task_assignments(family_member_id);

CREATE INDEX idx_grocery_items_category ON grocery_items(category);
CREATE INDEX idx_grocery_items_is_purchased ON grocery_items(is_purchased);
CREATE INDEX idx_grocery_items_list_id ON grocery_items(list_id);

CREATE INDEX idx_calendar_events_start_time ON calendar_events(start_time);
CREATE INDEX idx_calendar_events_end_time ON calendar_events(end_time);
CREATE INDEX idx_calendar_events_created_by ON calendar_events(created_by);

CREATE INDEX idx_event_attendees_event_id ON event_attendees(event_id);
CREATE INDEX idx_event_attendees_family_member_id ON event_attendees(family_member_id);

-- Trigger function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to tables that need updated_at
CREATE TRIGGER update_family_members_updated_at BEFORE UPDATE ON family_members FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_grocery_items_updated_at BEFORE UPDATE ON grocery_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_grocery_templates_updated_at BEFORE UPDATE ON grocery_templates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_calendar_events_updated_at BEFORE UPDATE ON calendar_events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Views for easier querying

-- Tasks with their assignees
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

-- Events with their attendees
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

-- Row Level Security (RLS) Policies

-- Enable RLS on all tables
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE grocery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE grocery_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE grocery_template_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_attendees ENABLE ROW LEVEL SECURITY;

-- Family members policies (each user can only see their own family)
CREATE POLICY "Users can view all family members" ON family_members
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own family member record" ON family_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own family member record" ON family_members
  FOR UPDATE USING (auth.uid() = user_id);

-- Tasks policies (family members can see and modify tasks they're involved with)
CREATE POLICY "Family members can view all tasks" ON tasks
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Authenticated users can create tasks" ON tasks
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid() AND fm.id = created_by
    )
  );

CREATE POLICY "Family members can update tasks" ON tasks
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Task creators can delete tasks" ON tasks
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid() AND fm.id = created_by
    )
  );

-- Task assignments policies
CREATE POLICY "Family members can view task assignments" ON task_assignments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family members can create task assignments" ON task_assignments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family members can update task assignments" ON task_assignments
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family members can delete task assignments" ON task_assignments
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

-- Grocery items policies
CREATE POLICY "Family members can view grocery items" ON grocery_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family members can create grocery items" ON grocery_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid() AND fm.id = added_by
    )
  );

CREATE POLICY "Family members can update grocery items" ON grocery_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family members can delete grocery items" ON grocery_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

-- Calendar events policies
CREATE POLICY "Family members can view calendar events" ON calendar_events
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family members can create calendar events" ON calendar_events
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid() AND fm.id = created_by
    )
  );

CREATE POLICY "Family members can update calendar events" ON calendar_events
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Event creators can delete calendar events" ON calendar_events
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid() AND fm.id = created_by
    )
  );

-- Event attendees policies
CREATE POLICY "Family members can view event attendees" ON event_attendees
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family members can manage event attendees" ON event_attendees
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

-- Similar policies for grocery templates and template items
CREATE POLICY "Family members can view grocery templates" ON grocery_templates
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family members can create grocery templates" ON grocery_templates
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid() AND fm.id = created_by
    )
  );

CREATE POLICY "Template creators can update grocery templates" ON grocery_templates
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid() AND fm.id = created_by
    )
  );

CREATE POLICY "Template creators can delete grocery templates" ON grocery_templates
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid() AND fm.id = created_by
    )
  );

CREATE POLICY "Family members can manage template items" ON grocery_template_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM family_members fm 
      WHERE fm.user_id = auth.uid()
    )
  );