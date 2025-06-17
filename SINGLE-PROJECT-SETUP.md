# 💰 Family Hub - Cost-Optimized Single Project Setup

## Overview
This setup uses **ONE Supabase project** with multiple schemas to separate environments, saving you $25-50/month while maintaining professional architecture.

## Architecture

```
Single Supabase Project
├── public schema (Production)
├── staging schema (Preview Deployments)  
└── dev schema (Local Development)

Automatic Environment Detection:
- main branch → public schema
- preview branches → staging schema
- local dev → dev schema
```

## Step 1: Create Your Single Supabase Project

Go to [supabase.com/dashboard](https://supabase.com/dashboard) and create:

```
Project Name: family-hub
Plan: Free (500MB database, 2GB bandwidth)
Region: [Choose closest to you]
Database Password: [Generate strong - SAVE IT!]
```

**Wait ~2 minutes for project initialization**

## Step 2: Get Your Credentials

In your project, go to **Settings > API** and copy:

```
Project URL: https://[your-project-id].supabase.co
anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Step 3: Provide Credentials for Automation

**Paste your 3 credentials here:**

```
URL: [paste your project URL]
anon: [paste your anon key]
service: [paste your service_role key]
```

## What I'll Automate Next:

### 1. **Multi-Schema Database Setup**
- Create staging and dev schemas
- Duplicate all tables to each schema
- Set up environment-based routing
- Configure RLS for schema isolation

### 2. **Smart Environment Detection**
- Production (main branch) → public schema
- Preview (feature branches) → staging schema  
- Development (local) → dev schema

### 3. **Vercel Configuration**
- Single set of environment variables
- Automatic schema switching
- Preview deployments with isolated data

### 4. **Cost Optimizations**
- Efficient indexes for free tier limits
- Query optimizations
- Connection pooling setup

## Benefits of This Approach

✅ **$0/month** - Stay on free tier  
✅ **Complete environment isolation** - No data mixing  
✅ **Professional architecture** - Same as enterprise setups  
✅ **Easy scaling** - Upgrade to Pro when needed  
✅ **Simple management** - One project to maintain

## Free Tier Limits (Plenty for Family Use)

- **Database**: 500MB (enough for years of family data)
- **Storage**: 1GB (thousands of photos)  
- **Bandwidth**: 2GB/month (heavy family usage)
- **Edge Functions**: 500K invocations
- **Realtime**: 200 concurrent connections

## Ready to Save Money?

Just paste your 3 credentials above and I'll set up the complete cost-optimized architecture! 🚀

---

**Note**: You can always upgrade to Pro later ($25/month) for:
- 8GB database
- 100GB storage  
- 50GB bandwidth
- Better performance
- Daily backups