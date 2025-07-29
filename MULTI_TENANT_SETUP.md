# Multi-Tenant Rails Application with Acts as Tenant + Devise

This Rails application demonstrates a complete multi-tenant setup using `acts_as_tenant` gem with Devise authentication.

## 🏗️ Architecture Overview

### Multi-Tenancy Strategy
- **Subdomain-based tenant isolation**: Each tenant has a unique subdomain (e.g., `acme.localhost:3000`)
- **Database row-level security**: All user data is automatically scoped to the current tenant
- **Shared application, isolated data**: Single codebase serves multiple tenants with isolated data

### Key Components

#### 1. Tenant Model (`app/models/tenant.rb`)
- Stores tenant information (name, subdomain)
- Validates subdomain uniqueness and format
- Has many users (with dependent destroy)

#### 2. User Model (`app/models/user.rb`)
- Standard Devise authentication
- `acts_as_tenant :tenant` - automatically scopes all queries to current tenant
- `belongs_to :tenant` - each user belongs to exactly one tenant
- Email uniqueness scoped to tenant (same email can exist across different tenants)

#### 3. Application Controller (`app/controllers/application_controller.rb`)
- `set_current_tenant_through_filter` - enables automatic tenant scoping
- `set_current_tenant` method - determines tenant from subdomain
- Handles tenant routing and fallbacks

#### 4. Custom Devise Registration (`app/controllers/users/registrations_controller.rb`)
- Ensures users can only register when accessing a tenant subdomain
- Automatically assigns the current tenant to new users
- Prevents registration on the main domain

## 🚀 Setup Instructions

### 1. Prerequisites
```bash
# Ensure you have the required gems
bundle install
```

### 2. Database Setup
```bash
# Run migrations
rails db:migrate

# Seed with sample tenants
rails db:seed
```

### 3. Start the Application
```bash
rails server
```

## 🌐 Testing the Multi-Tenancy

### Main Domain
- Visit: `http://localhost:3000`
- Shows landing page with available tenants
- Access admin panel to manage tenants

### Tenant Subdomains
After seeding, you can access:
- `http://acme.localhost:3000` - ACME Corporation workspace
- `http://techstart.localhost:3000` - TechStart Inc workspace  
- `http://global.localhost:3000` - Global Solutions workspace

### Admin Panel
- Visit: `http://localhost:3000/admin`
- View all tenants and their users
- Create new tenants
- Direct links to tenant workspaces

## 🔐 Authentication Flow

### User Registration
1. User visits tenant subdomain (e.g., `http://acme.localhost:3000`)
2. Clicks "Sign up"
3. Fills registration form
4. User is automatically assigned to the ACME tenant
5. All future logins are scoped to ACME tenant only

### User Sign In
1. User visits any tenant subdomain
2. Signs in with email/password
3. Can only access data within their tenant
4. Cannot see users or data from other tenants

## 🛡️ Data Isolation

### Automatic Scoping
```ruby
# When a user from ACME tenant is signed in:
User.all           # Returns only ACME users
current_user.tenant # Returns ACME tenant
```

### Manual Tenant Switching (Admin)
```ruby
# In admin controllers or console:
ActsAsTenant.with_tenant(some_tenant) do
  # Code here runs in context of some_tenant
  User.all # Returns users for some_tenant only
end
```

## 📁 Key Files

### Models
- `app/models/tenant.rb` - Tenant model with validations
- `app/models/user.rb` - User model with tenant association

### Controllers
- `app/controllers/application_controller.rb` - Tenant resolution logic
- `app/controllers/users/registrations_controller.rb` - Custom Devise registration
- `app/controllers/admin_controller.rb` - Admin panel for tenant management
- `app/controllers/home_controller.rb` - Landing page with tenant detection

### Configuration
- `config/initializers/acts_as_tenant.rb` - Acts as Tenant configuration
- `config/initializers/devise.rb` - Devise configuration
- `config/routes.rb` - Routing with custom Devise controllers

### Database
- `db/migrate/xxx_create_tenants.rb` - Tenant table migration
- `db/migrate/xxx_devise_create_users.rb` - User table with tenant reference
- `db/seeds.rb` - Sample tenant data

## 🎯 Features Implemented

✅ **Subdomain-based tenant routing**
✅ **Automatic tenant scoping for all queries** 
✅ **Devise authentication scoped to tenants**
✅ **Custom registration with tenant assignment**
✅ **Admin panel for tenant management**
✅ **Landing page with tenant discovery**
✅ **Database migrations with proper foreign keys**
✅ **Seed data for testing**
✅ **Responsive UI with Tailwind CSS**
✅ **Flash messages and error handling**

## 🔧 Configuration Notes

### Acts as Tenant Config
```ruby
# config/initializers/acts_as_tenant.rb
ActsAsTenant.configure do |config|
  config.require_tenant = true  # Ensures tenant is always set
end
```

### Devise Customization
- Custom registrations controller ensures tenant assignment
- Routes configured to use custom controller
- Email uniqueness scoped to tenant_id

### Development Setup
- Mailer configured for localhost:3000
- Subdomain testing works with .localhost domains
- No additional DNS configuration needed for development

## 🐛 Troubleshooting

### Common Issues
1. **Subdomain not working**: Ensure you're using `.localhost` in development
2. **Tenant not found**: Check subdomain spelling and tenant exists in database
3. **User can't register**: Ensure accessing via tenant subdomain, not main domain
4. **Data bleeding between tenants**: Verify `acts_as_tenant` is properly configured

### Testing Commands
```ruby
# Rails console testing
rails console

# Check tenants
Tenant.all

# Test tenant scoping
ActsAsTenant.with_tenant(Tenant.first) do
  puts User.count
end
```

This setup provides a solid foundation for a multi-tenant SaaS application with proper data isolation and user management.
