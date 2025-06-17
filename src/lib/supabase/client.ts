import { createBrowserClient } from '@supabase/ssr'
import type { Database } from './types'

// Determine environment based on various indicators
function getEnvironment(): 'production' | 'staging' | 'development' {
  // Check Vercel environment variable
  if (process.env.VERCEL_ENV === 'production' || process.env.NODE_ENV === 'production') {
    return 'production'
  }
  
  // Check if it's a preview deployment
  if (process.env.VERCEL_ENV === 'preview') {
    return 'staging'
  }
  
  // Check if running locally or in development
  if (process.env.NODE_ENV === 'development' || !process.env.VERCEL_ENV) {
    return 'development'
  }
  
  // Default to production for safety
  return 'production'
}

// Get the appropriate schema based on environment
function getSchema(): string {
  const env = getEnvironment()
  switch (env) {
    case 'production':
      return 'public'
    case 'staging':
      return 'staging'
    case 'development':
      return 'dev'
    default:
      return 'public'
  }
}

// Create Supabase client with environment configuration
export function createClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  
  const client = createBrowserClient<Database>(
    supabaseUrl,
    supabaseAnonKey,
    {
      db: {
        schema: getSchema()
      },
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true
      },
      global: {
        headers: {
          'x-app-environment': getEnvironment()
        }
      }
    }
  )
  
  // Set environment for RLS policies
  client.rpc('set_app_environment', { env: getEnvironment() }).then(() => {
    console.log(`Connected to Supabase with ${getEnvironment()} environment (${getSchema()} schema)`)
  }).catch(() => {
    // Ignore error if function doesn't exist yet
  })
  
  return client
}

// Export environment helpers
export { getEnvironment, getSchema }

// Singleton instance
let browserClient: ReturnType<typeof createClient> | undefined

export function getSupabaseClient() {
  if (!browserClient) {
    browserClient = createClient()
  }
  return browserClient
}