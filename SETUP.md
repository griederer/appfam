# 🚀 Family Hub - Complete Setup Guide

## Prerequisites
- GitHub account with repository access
- Vercel account 
- Supabase account
- Claude Code with MCP integration

## Part 1: Supabase MCP Integration (2 minutes)

### Step 1: Get Supabase Personal Access Token
1. Go to [supabase.com/dashboard/account/tokens](https://supabase.com/dashboard/account/tokens)
2. Click **"Generate new token"**
3. Name: `Claude Code MCP Integration`
4. Copy and save the token securely

### Step 2: Configure MCP in Project
1. Update `.mcp.json` with your access token:
```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--access-token",
        "YOUR_ACTUAL_TOKEN_HERE"
      ]
    }
  }
}
```

### Step 3: Enable MCP in Claude Code
The MCP integration will allow Claude to:
- Create and manage Supabase projects
- Run database migrations automatically
- Configure environment variables
- Generate optimized queries

## Part 2: Automated Supabase Setup (5 minutes)

### Step 1: Run Setup Script
```bash
# Set your Supabase access token
export SUPABASE_ACCESS_TOKEN="your_token_here"

# Install dependencies
npm install

# Run automated setup
npm run setup:supabase
```

### Step 2: Create Projects Manually (For Now)
Until API project creation is available, create these projects in [Supabase Dashboard](https://supabase.com/dashboard):

```bash
Project 1: family-hub-dev
Project 2: family-hub-staging  
Project 3: family-hub-prod

# For each project:
# - Choose the same region (closest to you)
# - Use strong passwords
# - Save all credentials securely
```

### Step 3: Get Project Credentials
For each project, go to **Settings > API** and copy:
- Project URL (e.g., `https://abcdef.supabase.co`)
- anon public key
- service_role secret key

## Part 3: Database Migration with MCP (1 minute)

With MCP integration, Claude can run migrations automatically:

### Option A: Via Claude Code (Recommended)
```
Tell Claude: "Please run the database migration for all three Supabase projects using the schema in supabase/migrations/20240101_initial_schema.sql"
```

### Option B: Manual SQL Editor
1. In each Supabase project, go to **SQL Editor**
2. Copy content from `supabase/migrations/20240101_initial_schema.sql`
3. Run the migration
4. Verify tables are created

### Option C: Supabase CLI
```bash
# For each environment
supabase link --project-ref your-project-id
supabase db push
```

## Part 4: Vercel Setup (3 minutes)

### Step 1: Connect Repository
1. Go to [vercel.com/new](https://vercel.com/new)
2. Import `griederer/appfam`
3. Project name: `family-hub`
4. Deploy (will fail - that's expected)

### Step 2: Configure Environment Variables
In Vercel project settings > Environment Variables:

```bash
# Production
NEXT_PUBLIC_SUPABASE_URL_PRODUCTION=https://your-prod.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY_PRODUCTION=eyJ...
SUPABASE_SERVICE_ROLE_KEY_PRODUCTION=eyJ...

# Staging
NEXT_PUBLIC_SUPABASE_URL_STAGING=https://your-staging.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY_STAGING=eyJ...
SUPABASE_SERVICE_ROLE_KEY_STAGING=eyJ...

# Development
NEXT_PUBLIC_SUPABASE_URL_DEVELOPMENT=https://your-dev.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY_DEVELOPMENT=eyJ...
SUPABASE_SERVICE_ROLE_KEY_DEVELOPMENT=eyJ...

# Fallback (Production)
NEXT_PUBLIC_SUPABASE_URL=https://your-prod.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# App Config
NEXT_PUBLIC_APP_URL=https://family-hub.vercel.app
NEXT_PUBLIC_APP_NAME=Family Hub
```

### Step 3: GitHub Actions Secrets
In GitHub repository > Settings > Secrets:

```bash
VERCEL_TOKEN=         # From Vercel Settings > Tokens
VERCEL_ORG_ID=        # From Vercel project settings
VERCEL_PROJECT_ID=    # From Vercel project settings
```

## Part 5: Test Cloud Workflow (2 minutes)

### Step 1: Trigger Production Deploy
- In Vercel, click "Redeploy" on latest deployment
- Should now succeed with Supabase connection

### Step 2: Test Preview Deployment
```bash
git checkout -b test-mcp-setup
echo "# MCP Setup Complete" >> MCP-SETUP.md
git add .
git commit -m "test: Verify MCP and cloud workflow"
git push origin test-mcp-setup
```

Watch GitHub Actions create preview deployment automatically!

### Step 3: Verify Everything Works
Visit your URLs:
- Production: `https://family-hub.vercel.app`
- Preview: `https://family-hub-git-test-mcp-setup.vercel.app`

## Part 6: MCP-Enhanced Development (Ongoing)

With MCP integration, you can now ask Claude to:

```bash
# Database operations
"Create a new migration to add a notes field to tasks"
"Query all tasks for the Gonzalo family from the last week"
"Optimize the database indexes for better performance"

# Schema management  
"Generate TypeScript types from the current database schema"
"Create a new table for task templates"
"Add a foreign key relationship between X and Y tables"

# Data analysis
"Show me the most frequently purchased grocery items"
"Analyze task completion patterns by family member"
"Generate a report of calendar events for this month"
```

## ✅ Verification Checklist

- [ ] Supabase MCP integration configured
- [ ] 3 Supabase projects created
- [ ] Database migrations completed
- [ ] Vercel project connected
- [ ] Environment variables configured
- [ ] GitHub Actions secrets added
- [ ] Production deployment working
- [ ] Preview deployments working
- [ ] MCP tools accessible to Claude

## 🎯 Next Steps

1. **Open GitHub Codespace** for cloud development
2. **Start Phase 1 development** with automated Supabase operations
3. **Use MCP for database queries and schema changes**
4. **Deploy and test** with automatic preview URLs

## 🔧 MCP Commands Reference

```bash
# Ask Claude these questions to leverage MCP:

"Show me all tables in the development database"
"Create a query to get today's tasks for María Paz"
"Add a new grocery category for 'frozen' items"
"Generate sample data for testing the calendar feature"
"Check the performance of the tasks_with_assignees view"
"Create a backup of the current database schema"
```

The MCP integration makes Supabase operations seamless - Claude can now directly interact with your database, run queries, and manage schema changes automatically! 🚀