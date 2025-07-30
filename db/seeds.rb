# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating seed data..."

# Create ACME organization without tenant context
ActsAsTenant.without_tenant do
  acme_org = Organization.create!(
    name: "ACME Corporation",
    description: "Leading technology company"
  )

  puts "Created organization: #{acme_org.name}"

  # Now set the tenant context and create users
  ActsAsTenant.with_tenant(acme_org) do
    # Create admin user for ACME
    acme_admin = User.create!(
      email: "admin@acme.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "John",
      last_name: "Doe",
      organization: acme_org,
      confirmed_at: Time.current
    )

    puts "Created admin user: #{acme_admin.email}"

    # Set the admin as owner
    acme_org.update!(owner: acme_admin)

    puts "Set #{acme_admin.email} as owner of #{acme_org.name}"
    
    # Create a regular user
    regular_user = User.create!(
      email: "user@acme.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Jane",
      last_name: "Smith",
      confirmed_at: Time.current
    )
    
    # Add regular user to organization
    OrganizationMembership.create!(
      user: regular_user,
      organization: acme_org,
      role: "member"
    )
    
    puts "Created regular user: #{regular_user.email}"
  end
  
  # Create Startup organization
  startup_org = Organization.create!(
    name: "Startup Inc",
    description: "Innovative startup company"
  )

  ActsAsTenant.with_tenant(startup_org) do
    startup_admin = User.create!(
      email: "founder@startup.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Alice",
      last_name: "Johnson",
      organization: startup_org,
      confirmed_at: Time.current
    )

    startup_org.update!(owner: startup_admin)
    puts "Created startup organization: #{startup_org.name}"
  end
end

puts "Seed data created successfully!"
puts ""
puts "You can test the application by visiting:"
puts "- http://localhost:3000"
puts "  Admin: admin@acme.com / password123"
puts "  User: user@acme.com / password123"
puts "  Startup Admin: founder@startup.com / password123"
