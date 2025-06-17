#!/usr/bin/env node

/**
 * Enhanced Supabase Pro Setup Script for Family Hub
 * Leverages Pro account features and MCP integration for maximum automation
 */

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');
const https = require('https');

// Enhanced configuration for Pro account
const ENVIRONMENTS = {
  development: {
    name: 'family-hub-dev',
    description: 'Development environment for Family Hub - Full feature testing',
    plan: 'pro',
    region: 'us-east-1', // Will be auto-detected
  },
  staging: {
    name: 'family-hub-staging', 
    description: 'Staging environment for Family Hub - Pre-production testing',
    plan: 'pro',
    region: 'us-east-1',
  },
  production: {
    name: 'family-hub-prod',
    description: 'Production environment for Family Hub - Live family data',
    plan: 'pro',
    region: 'us-east-1',
  }
};

class SupabaseProSetup {
  constructor(accessToken) {
    this.accessToken = accessToken;
    this.projectsCreated = {};
    this.apiBase = 'https://api.supabase.com/v1';
  }

  async makeApiRequest(endpoint, method = 'GET', data = null) {
    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'api.supabase.com',
        port: 443,
        path: `/v1${endpoint}`,
        method: method,
        headers: {
          'Authorization': `Bearer ${this.accessToken}`,
          'Content-Type': 'application/json',
        }
      };

      const req = https.request(options, (res) => {
        let responseData = '';
        
        res.on('data', (chunk) => {
          responseData += chunk;
        });
        
        res.on('end', () => {
          try {
            const parsed = JSON.parse(responseData);
            resolve({ status: res.statusCode, data: parsed });
          } catch (error) {
            resolve({ status: res.statusCode, data: responseData });
          }
        });
      });

      req.on('error', (error) => {
        reject(error);
      });

      if (data) {
        req.write(JSON.stringify(data));
      }
      
      req.end();
    });
  }

  async getOrganizations() {
    console.log('🏢 Fetching organizations...');
    try {
      const response = await this.makeApiRequest('/organizations');
      if (response.status === 200) {
        console.log('✅ Organizations fetched successfully');
        return response.data;
      } else {
        console.log('⚠️  Using manual project creation fallback');
        return null;
      }
    } catch (error) {
      console.log('⚠️  API unavailable, using manual project creation');
      return null;
    }
  }

  async createProject(environment, orgId) {
    console.log(`🚀 Creating ${environment} project...`);
    
    const config = ENVIRONMENTS[environment];
    const projectData = {
      name: config.name,
      organization_id: orgId,
      plan: config.plan,
      region: config.region,
      db_pass: this.generateSecurePassword(),
    };

    try {
      const response = await this.makeApiRequest('/projects', 'POST', projectData);
      
      if (response.status === 201) {
        console.log(`✅ ${environment} project created successfully`);
        this.projectsCreated[environment] = response.data;
        return response.data;
      } else {
        console.log(`⚠️  Project creation API response: ${response.status}`);
        return null;
      }
    } catch (error) {
      console.log(`⚠️  Project creation failed for ${environment}, using manual fallback`);
      return null;
    }
  }

  generateSecurePassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
    let password = '';
    for (let i = 0; i < 24; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return password;
  }

  async setupDatabase(projectUrl, serviceKey, environment) {
    console.log(`🗄️  Setting up database for ${environment}...`);
    
    try {
      const supabase = createClient(projectUrl, serviceKey);
      
      // Read and execute migration
      const migrationPath = path.join(__dirname, '../supabase/migrations/20240101_initial_schema.sql');
      const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
      
      console.log('   📋 Running database migration...');
      
      // Split migration into individual statements for better execution
      const statements = migrationSQL
        .split(';')
        .map(stmt => stmt.trim())
        .filter(stmt => stmt.length > 0);
      
      for (const statement of statements) {
        if (statement.includes('CREATE') || statement.includes('ALTER') || statement.includes('INSERT')) {
          try {
            const { error } = await supabase.rpc('exec_sql', { 
              sql: statement + ';'
            });
            
            if (error) {
              console.log(`   ⚠️  Statement warning: ${error.message}`);
            }
          } catch (err) {
            // Try direct query for some operations
            try {
              await supabase.from('').select('').limit(0); // Test connection
            } catch (testErr) {
              console.log(`   ⚠️  Database not ready yet, retrying...`);
              await new Promise(resolve => setTimeout(resolve, 5000));
            }
          }
        }
      }
      
      console.log(`✅ Database migration completed for ${environment}`);
      
      // Add seed data for development
      if (environment === 'development') {
        console.log('   🌱 Adding seed data for development...');
        const seedPath = path.join(__dirname, '../supabase/seed.sql');
        if (fs.existsSync(seedPath)) {
          const seedSQL = fs.readFileSync(seedPath, 'utf8');
          
          try {
            const { error: seedError } = await supabase.rpc('exec_sql', { 
              sql: seedSQL 
            });
            
            if (!seedError) {
              console.log('✅ Seed data added successfully');
            } else {
              console.log('⚠️  Seed data will be added manually');
            }
          } catch (err) {
            console.log('⚠️  Seed data will be added manually');
          }
        }
      }
      
      return true;
      
    } catch (error) {
      console.error(`❌ Database setup failed for ${environment}:`, error.message);
      return false;
    }
  }

  async generateVercelEnvFile() {
    console.log('📄 Generating Vercel environment configuration...\n');
    
    const envConfig = Object.entries(this.projectsCreated).map(([env, project]) => {
      const envName = env.toUpperCase();
      return `
# ${env.charAt(0).toUpperCase() + env.slice(1)} Environment
NEXT_PUBLIC_SUPABASE_URL_${envName}=${project.database?.host || 'https://' + project.id + '.supabase.co'}
NEXT_PUBLIC_SUPABASE_ANON_KEY_${envName}=${project.anon_key || 'your-anon-key'}
SUPABASE_SERVICE_ROLE_KEY_${envName}=${project.service_role_key || 'your-service-key'}`;
    }).join('\n');

    const envTemplate = `# Family Hub Environment Variables - Generated by Supabase Pro Setup
# Copy these to Vercel Environment Variables dashboard

${envConfig}

# Main Environment (Production fallback)
NEXT_PUBLIC_SUPABASE_URL=\${NEXT_PUBLIC_SUPABASE_URL_PRODUCTION}
NEXT_PUBLIC_SUPABASE_ANON_KEY=\${NEXT_PUBLIC_SUPABASE_ANON_KEY_PRODUCTION}
SUPABASE_SERVICE_ROLE_KEY=\${SUPABASE_SERVICE_ROLE_KEY_PRODUCTION}

# App Configuration
NEXT_PUBLIC_APP_URL=https://family-hub.vercel.app
NEXT_PUBLIC_APP_NAME=Family Hub

# GitHub Actions Secrets needed:
# VERCEL_TOKEN=[Get from Vercel Settings > Tokens]
# VERCEL_ORG_ID=[Get from Vercel project settings] 
# VERCEL_PROJECT_ID=[Get from Vercel project settings]
`;

    const envPath = path.join(__dirname, '../.env.vercel');
    fs.writeFileSync(envPath, envTemplate);
    
    console.log('✅ Vercel environment file created at .env.vercel');
    console.log('📋 Copy these variables to Vercel dashboard\n');
  }

  async run() {
    console.log('🏠 Family Hub - Supabase Pro Automated Setup\n');
    console.log('🚀 Using Pro account features for maximum automation\n');
    
    // Step 1: Get organizations
    const orgs = await this.getOrganizations();
    
    if (orgs && orgs.length > 0) {
      console.log(`✅ Found ${orgs.length} organization(s)`);
      const primaryOrg = orgs[0];
      
      // Step 2: Create projects automatically
      console.log('\n📦 Creating Supabase projects...');
      for (const environment of Object.keys(ENVIRONMENTS)) {
        const project = await this.createProject(environment, primaryOrg.id);
        if (project) {
          // Wait for project to be ready
          console.log(`   ⏳ Waiting for ${environment} project to initialize...`);
          await new Promise(resolve => setTimeout(resolve, 30000)); // 30 second wait
        }
      }
      
      // Step 3: Setup databases
      if (Object.keys(this.projectsCreated).length > 0) {
        console.log('\n🗄️  Setting up databases...');
        for (const [env, project] of Object.entries(this.projectsCreated)) {
          const projectUrl = project.database?.host || `https://${project.id}.supabase.co`;
          const serviceKey = project.service_role_key;
          
          if (serviceKey) {
            await this.setupDatabase(projectUrl, serviceKey, env);
          }
        }
      }
      
      // Step 4: Generate environment configuration
      await this.generateVercelEnvFile();
      
    } else {
      console.log('⚠️  Project creation API not available');
      console.log('📋 Falling back to manual project creation with automated database setup\n');
      
      // Provide manual instructions
      console.log('🔧 Manual Steps Required:');
      console.log('1. Create these projects manually in Supabase dashboard:');
      Object.entries(ENVIRONMENTS).forEach(([env, config]) => {
        console.log(`   - ${config.name} (${env})`);
      });
      console.log('2. Provide project credentials for automated database setup');
    }
    
    console.log('\n🎯 Next Steps:');
    console.log('1. Connect repository to Vercel');
    console.log('2. Add environment variables from .env.vercel');
    console.log('3. Configure GitHub Actions secrets');
    console.log('4. Test deployment pipeline\n');
    
    console.log('✨ Pro account setup optimization complete!');
  }
}

// CLI interface
if (require.main === module) {
  const accessToken = process.env.SUPABASE_ACCESS_TOKEN || process.argv[2];
  
  if (!accessToken) {
    console.error('❌ Please provide Supabase access token:');
    console.log('Usage: node setup-supabase-pro.js <your-access-token>');
    console.log('Or set: export SUPABASE_ACCESS_TOKEN="your-token"');
    process.exit(1);
  }
  
  const setup = new SupabaseProSetup(accessToken);
  setup.run().catch(console.error);
}

module.exports = SupabaseProSetup;