-- Family Hub Seed Data
-- This file contains test data for development and testing

-- Note: In production, family members will be created through the auth signup process
-- This seed data is for development/testing purposes only

-- Insert test family members (these will need to match actual auth.users in your Supabase project)
-- Replace these UUIDs with actual user IDs from your auth.users table

INSERT INTO family_members (id, user_id, name, email, color, is_active) VALUES
  ('11111111-1111-1111-1111-111111111111', NULL, 'Gonzalo', 'gonzalo@family.com', '#007AFF', true),
  ('22222222-2222-2222-2222-222222222222', NULL, 'María Paz', 'mariapaz@family.com', '#FF3B30', true),
  ('33333333-3333-3333-3333-333333333333', NULL, 'Borja', 'borja@family.com', '#34C759', true),
  ('44444444-4444-4444-4444-444444444444', NULL, 'Melody', 'melody@family.com', '#AF52DE', true);

-- Insert sample tasks
INSERT INTO tasks (id, title, description, status, priority, due_date, time_group, list_type, created_by) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Buy groceries for the week', 'Get items from the grocery list', 'pending', 'high', NOW() + INTERVAL '2 hours', 'morning', 'today', '11111111-1111-1111-1111-111111111111'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Pick up kids from school', 'Borja and Melody need pickup at 3pm', 'pending', 'urgent', NOW() + INTERVAL '6 hours', 'afternoon', 'today', '22222222-2222-2222-2222-222222222222'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Plan weekend activities', 'Find something fun for the family', 'pending', 'medium', NOW() + INTERVAL '2 days', NULL, 'upcoming', '11111111-1111-1111-1111-111111111111'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Soccer practice preparation', 'Get Borja ready for soccer practice', 'pending', 'medium', NOW() + INTERVAL '1 day', 'afternoon', 'upcoming', '22222222-2222-2222-2222-222222222222'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Music lesson homework', 'Practice piano for 30 minutes', 'pending', 'medium', NOW() + INTERVAL '1 day', 'evening', 'today', '44444444-4444-4444-4444-444444444444');

-- Insert task assignments
INSERT INTO task_assignments (task_id, family_member_id) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '33333333-3333-3333-3333-333333333333'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '44444444-4444-4444-4444-444444444444');

-- Insert sample grocery items
INSERT INTO grocery_items (id, name, quantity, unit, category, notes, is_purchased, always_buy, added_by, list_id) VALUES
  ('gggggggg-gggg-gggg-gggg-gggggggggggg', 'Milk', 2, 'L', 'dairy', '2% milk preferred', false, true, '22222222-2222-2222-2222-222222222222', 'current-list'),
  ('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 'Bread', 1, 'loaf', 'pantry', 'Whole grain', false, true, '11111111-1111-1111-1111-111111111111', 'current-list'),
  ('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', 'Tomatoes', 1, 'kg', 'produce', 'For salads', false, false, '22222222-2222-2222-2222-222222222222', 'current-list'),
  ('jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', 'Chicken breast', 500, 'g', 'meat', 'Organic if available', false, false, '11111111-1111-1111-1111-111111111111', 'current-list'),
  ('kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', 'Cleaning supplies', 1, 'set', 'household', 'All-purpose cleaner', false, false, '22222222-2222-2222-2222-222222222222', 'current-list'),
  ('llllllll-llll-llll-llll-llllllllllll', 'Eggs', 12, 'pieces', 'dairy', 'Free range', true, true, '11111111-1111-1111-1111-111111111111', 'current-list'),
  ('mmmmmmmm-mmmm-mmmm-mmmm-mmmmmmmmmmmm', 'Apples', 1, 'kg', 'produce', 'Red apples for kids', false, true, '22222222-2222-2222-2222-222222222222', 'current-list');

-- Insert grocery templates
INSERT INTO grocery_templates (id, name, description, created_by, is_public) VALUES
  ('tttttttt-tttt-tttt-tttt-tttttttttttt', 'Weekly Essentials', 'Basic items we buy every week', '11111111-1111-1111-1111-111111111111', true),
  ('uuuuuuuu-uuuu-uuuu-uuuu-uuuuuuuuuuuu', 'Party Supplies', 'Items for birthday parties and celebrations', '22222222-2222-2222-2222-222222222222', true);

-- Insert template items (link grocery items to templates)
INSERT INTO grocery_template_items (template_id, grocery_item_id) VALUES
  ('tttttttt-tttt-tttt-tttt-tttttttttttt', 'gggggggg-gggg-gggg-gggg-gggggggggggg'), -- Milk
  ('tttttttt-tttt-tttt-tttt-tttttttttttt', 'hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh'), -- Bread
  ('tttttttt-tttt-tttt-tttt-tttttttttttt', 'llllllll-llll-llll-llll-llllllllllll'), -- Eggs
  ('tttttttt-tttt-tttt-tttt-tttttttttttt', 'mmmmmmmm-mmmm-mmmm-mmmm-mmmmmmmmmmmm'); -- Apples

-- Insert sample calendar events
INSERT INTO calendar_events (id, title, description, event_type, start_time, end_time, all_day, location, created_by) VALUES
  ('pppppppp-pppp-pppp-pppp-pppppppppppp', 'Doctor Appointment', 'Annual checkup for María Paz', 'appointment', NOW() + INTERVAL '3 days' + INTERVAL '11 hours', NOW() + INTERVAL '3 days' + INTERVAL '12 hours', false, 'Family Health Clinic', '22222222-2222-2222-2222-222222222222'),
  ('qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqqqq', 'Soccer Practice', 'Borja weekly soccer training', 'other', NOW() + INTERVAL '2 days' + INTERVAL '15 hours', NOW() + INTERVAL '2 days' + INTERVAL '16 hours' + INTERVAL '30 minutes', false, 'Local Sports Center', '33333333-3333-3333-3333-333333333333'),
  ('rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrrrr', 'Piano Lesson', 'Melody piano lesson with teacher', 'other', NOW() + INTERVAL '4 days' + INTERVAL '16 hours', NOW() + INTERVAL '4 days' + INTERVAL '17 hours', false, 'Music Academy', '44444444-4444-4444-4444-444444444444'),
  ('ssssssss-ssss-ssss-ssss-ssssssssssss', 'Family Movie Night', 'Weekly family bonding time', 'other', NOW() + INTERVAL '5 days' + INTERVAL '19 hours', NOW() + INTERVAL '5 days' + INTERVAL '21 hours', false, 'Home', '11111111-1111-1111-1111-111111111111'),
  ('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvvvv', 'School Parent Meeting', 'Discussion about kids progress', 'meeting', NOW() + INTERVAL '1 week' + INTERVAL '14 hours', NOW() + INTERVAL '1 week' + INTERVAL '15 hours', false, 'School', '11111111-1111-1111-1111-111111111111');

-- Insert event attendees
INSERT INTO event_attendees (event_id, family_member_id, rsvp_status) VALUES
  ('pppppppp-pppp-pppp-pppp-pppppppppppp', '22222222-2222-2222-2222-222222222222', 'accepted'),
  ('qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqqqq', '33333333-3333-3333-3333-333333333333', 'accepted'),
  ('qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqqqq', '11111111-1111-1111-1111-111111111111', 'accepted'), -- Gonzalo drives Borja
  ('rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrrrr', '44444444-4444-4444-4444-444444444444', 'accepted'),
  ('rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrrrr', '22222222-2222-2222-2222-222222222222', 'accepted'), -- María Paz takes Melody
  ('ssssssss-ssss-ssss-ssss-ssssssssssss', '11111111-1111-1111-1111-111111111111', 'accepted'),
  ('ssssssss-ssss-ssss-ssss-ssssssssssss', '22222222-2222-2222-2222-222222222222', 'accepted'),
  ('ssssssss-ssss-ssss-ssss-ssssssssssss', '33333333-3333-3333-3333-333333333333', 'accepted'),
  ('ssssssss-ssss-ssss-ssss-ssssssssssss', '44444444-4444-4444-4444-444444444444', 'accepted'),
  ('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvvvv', '11111111-1111-1111-1111-111111111111', 'accepted'),
  ('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvvvv', '22222222-2222-2222-2222-222222222222', 'accepted');

-- Update last_bought for some grocery items to show purchase history
UPDATE grocery_items SET 
  last_bought = NOW() - INTERVAL '5 days',
  purchased_by = '11111111-1111-1111-1111-111111111111'
WHERE name = 'Eggs';

UPDATE grocery_items SET 
  last_bought = NOW() - INTERVAL '3 days',
  purchased_by = '22222222-2222-2222-2222-222222222222'
WHERE name = 'Milk';

-- Mark some tasks as completed
UPDATE tasks SET 
  status = 'completed',
  completed_at = NOW() - INTERVAL '1 day'
WHERE title = 'Pick up kids from school';

-- Add some completed grocery items from previous shopping
INSERT INTO grocery_items (name, quantity, unit, category, notes, is_purchased, always_buy, added_by, purchased_by, last_bought, list_id) VALUES
  ('Rice', 1, 'kg', 'pantry', 'Basmati rice', true, true, '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '1 week', 'previous-list'),
  ('Bananas', 1, 'bunch', 'produce', 'Yellow bananas', true, true, '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '1 week', 'previous-list'),
  ('Yogurt', 4, 'cups', 'dairy', 'Greek yogurt', true, false, '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '1 week', 'previous-list');

-- Add some tasks for different time periods to test views
INSERT INTO tasks (title, description, status, priority, due_date, time_group, list_type, created_by) VALUES
  ('Morning exercise', 'Go for a 30-minute walk', 'pending', 'medium', NOW() + INTERVAL '1 day' + INTERVAL '7 hours', 'morning', 'today', '11111111-1111-1111-1111-111111111111'),
  ('Lunch prep', 'Prepare healthy lunch for family', 'pending', 'medium', NOW() + INTERVAL '1 day' + INTERVAL '12 hours', 'afternoon', 'today', '22222222-2222-2222-2222-222222222222'),
  ('Bedtime story', 'Read story to Melody', 'pending', 'low', NOW() + INTERVAL '1 day' + INTERVAL '20 hours', 'evening', 'today', '11111111-1111-1111-1111-111111111111'),
  ('Call grandparents', 'Weekly check-in call', 'pending', 'medium', NULL, NULL, 'anytime', '22222222-2222-2222-2222-222222222222'),
  ('Plan summer vacation', 'Research and book family vacation', 'pending', 'low', NULL, NULL, 'someday', '11111111-1111-1111-1111-111111111111');

-- Add task assignments for the new tasks
INSERT INTO task_assignments (task_id, family_member_id)
SELECT t.id, '11111111-1111-1111-1111-111111111111'
FROM tasks t WHERE t.title = 'Morning exercise';

INSERT INTO task_assignments (task_id, family_member_id)
SELECT t.id, '22222222-2222-2222-2222-222222222222'
FROM tasks t WHERE t.title = 'Lunch prep';

INSERT INTO task_assignments (task_id, family_member_id)
SELECT t.id, '11111111-1111-1111-1111-111111111111'
FROM tasks t WHERE t.title = 'Bedtime story';

INSERT INTO task_assignments (task_id, family_member_id)
SELECT t.id, '44444444-4444-4444-4444-444444444444'
FROM tasks t WHERE t.title = 'Bedtime story';

INSERT INTO task_assignments (task_id, family_member_id)
SELECT t.id, '22222222-2222-2222-2222-222222222222'
FROM tasks t WHERE t.title = 'Call grandparents';

INSERT INTO task_assignments (task_id, family_member_id)
SELECT t.id, '11111111-1111-1111-1111-111111111111'
FROM tasks t WHERE t.title = 'Plan summer vacation';

INSERT INTO task_assignments (task_id, family_member_id)
SELECT t.id, '22222222-2222-2222-2222-222222222222'
FROM tasks t WHERE t.title = 'Plan summer vacation';