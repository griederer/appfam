// Core type definitions for Family Hub

export type FamilyMember = 'Gonzalo' | 'María Paz' | 'Borja' | 'Melody'

export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled'
export type TaskPriority = 'low' | 'medium' | 'high' | 'urgent'
export type TaskList = 'inbox' | 'today' | 'upcoming' | 'anytime' | 'someday'
export type TimeGroup = 'morning' | 'afternoon' | 'evening'

export type GroceryCategory = 'produce' | 'dairy' | 'meat' | 'pantry' | 'household' | 'other'
export type EventType = 'appointment' | 'meeting' | 'reminder' | 'birthday' | 'holiday' | 'other'
export type RsvpStatus = 'pending' | 'accepted' | 'declined' | 'tentative'

// Database models (matching Supabase schema)
export interface FamilyMemberData {
  id: string
  user_id?: string
  name: string
  email?: string
  avatar_url?: string
  color: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Task {
  id: string
  title: string
  description?: string
  status: TaskStatus
  priority: TaskPriority
  due_date?: string
  time_group?: TimeGroup
  list_type: TaskList
  created_by?: string
  completed_at?: string
  created_at: string
  updated_at: string
  assignees?: FamilyMemberData[]
}

export interface TaskAssignment {
  id: string
  task_id: string
  family_member_id: string
  assigned_at: string
}

export interface GroceryItem {
  id: string
  name: string
  quantity?: number
  unit?: string
  category: GroceryCategory
  notes?: string
  is_purchased: boolean
  always_buy: boolean
  last_bought?: string
  added_by?: string
  purchased_by?: string
  list_id?: string
  created_at: string
  updated_at: string
}

export interface GroceryTemplate {
  id: string
  name: string
  description?: string
  created_by?: string
  is_public: boolean
  created_at: string
  updated_at: string
}

export interface GroceryTemplateItem {
  id: string
  template_id: string
  grocery_item_id: string
}

export interface CalendarEvent {
  id: string
  title: string
  description?: string
  event_type: EventType
  start_time: string
  end_time: string
  all_day: boolean
  location?: string
  recurring_config?: any
  created_by?: string
  created_at: string
  updated_at: string
  attendees?: (FamilyMemberData & { rsvp_status: RsvpStatus })[]
}

export interface EventAttendee {
  id: string
  event_id: string
  family_member_id: string
  rsvp_status: RsvpStatus
  created_at: string
}

// UI-specific types
export interface TaskWithAssignees extends Task {
  assignees: FamilyMemberData[]
}

export interface EventWithAttendees extends CalendarEvent {
  attendees: (FamilyMemberData & { rsvp_status: RsvpStatus })[]
}

export interface TasksByTimeGroup {
  morning: Task[]
  afternoon: Task[]
  evening: Task[]
  noTime: Task[]
}

export interface GroceryListByCategory {
  produce: GroceryItem[]
  dairy: GroceryItem[]
  meat: GroceryItem[]
  pantry: GroceryItem[]
  household: GroceryItem[]
  other: GroceryItem[]
}

// Form types
export interface CreateTaskForm {
  title: string
  description?: string
  priority: TaskPriority
  due_date?: Date
  time_group?: TimeGroup
  assignees: string[]
}

export interface CreateGroceryItemForm {
  name: string
  quantity?: number
  unit?: string
  category: GroceryCategory
  notes?: string
  always_buy?: boolean
}

export interface CreateEventForm {
  title: string
  description?: string
  event_type: EventType
  start_time: Date
  end_time: Date
  all_day: boolean
  location?: string
  attendees: string[]
}

// API response types
export interface ApiResponse<T> {
  data: T | null
  error: string | null
  success: boolean
}

export interface PaginatedResponse<T> {
  data: T[]
  count: number
  page: number
  pageSize: number
  totalPages: number
}

// Store types (for Zustand)
export interface AuthState {
  user: FamilyMemberData | null
  isAuthenticated: boolean
  isLoading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signUp: (email: string, password: string, name: string) => Promise<void>
  signOut: () => Promise<void>
  updateProfile: (updates: Partial<FamilyMemberData>) => Promise<void>
}

export interface TasksState {
  tasks: Task[]
  loading: boolean
  error: string | null
  selectedList: TaskList
  fetchTasks: () => Promise<void>
  createTask: (task: CreateTaskForm) => Promise<void>
  updateTask: (id: string, updates: Partial<Task>) => Promise<void>
  deleteTask: (id: string) => Promise<void>
  setSelectedList: (list: TaskList) => void
}

export interface GroceryState {
  items: GroceryItem[]
  templates: GroceryTemplate[]
  loading: boolean
  error: string | null
  fetchItems: () => Promise<void>
  createItem: (item: CreateGroceryItemForm) => Promise<void>
  updateItem: (id: string, updates: Partial<GroceryItem>) => Promise<void>
  deleteItem: (id: string) => Promise<void>
  togglePurchased: (id: string) => Promise<void>
  fetchTemplates: () => Promise<void>
  createTemplate: (name: string, description?: string) => Promise<void>
  useTemplate: (templateId: string) => Promise<void>
}

export interface CalendarState {
  events: CalendarEvent[]
  selectedDate: Date
  loading: boolean
  error: string | null
  fetchEvents: (month: number, year: number) => Promise<void>
  createEvent: (event: CreateEventForm) => Promise<void>
  updateEvent: (id: string, updates: Partial<CalendarEvent>) => Promise<void>
  deleteEvent: (id: string) => Promise<void>
  setSelectedDate: (date: Date) => void
}

// Utility types
export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P]
}

export type OptionalExceptFor<T, TRequired extends keyof T> = Partial<T> & Pick<T, TRequired>

export type WithTimestamps<T> = T & {
  created_at: string
  updated_at: string
}

// Constants
export const FAMILY_COLORS = {
  Gonzalo: '#007AFF',
  'María Paz': '#FF3B30',
  Borja: '#34C759',
  Melody: '#AF52DE',
} as const

export const TASK_PRIORITIES: TaskPriority[] = ['low', 'medium', 'high', 'urgent']
export const TASK_STATUSES: TaskStatus[] = ['pending', 'in_progress', 'completed', 'cancelled']
export const TASK_LISTS: TaskList[] = ['inbox', 'today', 'upcoming', 'anytime', 'someday']
export const TIME_GROUPS: TimeGroup[] = ['morning', 'afternoon', 'evening']
export const GROCERY_CATEGORIES: GroceryCategory[] = ['produce', 'dairy', 'meat', 'pantry', 'household', 'other']
export const EVENT_TYPES: EventType[] = ['appointment', 'meeting', 'reminder', 'birthday', 'holiday', 'other']
export const RSVP_STATUSES: RsvpStatus[] = ['pending', 'accepted', 'declined', 'tentative']

// Error types
export class FamilyHubError extends Error {
  constructor(
    message: string,
    public code?: string,
    public statusCode?: number
  ) {
    super(message)
    this.name = 'FamilyHubError'
  }
}

export class ValidationError extends FamilyHubError {
  constructor(message: string, public field?: string) {
    super(message, 'VALIDATION_ERROR', 400)
    this.name = 'ValidationError'
  }
}

export class AuthenticationError extends FamilyHubError {
  constructor(message: string = 'Authentication required') {
    super(message, 'AUTH_ERROR', 401)
    this.name = 'AuthenticationError'
  }
}

export class AuthorizationError extends FamilyHubError {
  constructor(message: string = 'Access denied') {
    super(message, 'AUTHORIZATION_ERROR', 403)
    this.name = 'AuthorizationError'
  }
}

export class NotFoundError extends FamilyHubError {
  constructor(resource: string = 'Resource') {
    super(`${resource} not found`, 'NOT_FOUND', 404)
    this.name = 'NotFoundError'
  }
}