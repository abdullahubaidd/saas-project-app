# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample tenants
tenants = [
  { name: "ACME Corporation", subdomain: "acme" },
  { name: "TechStart Inc", subdomain: "techstart" },
  { name: "Global Solutions", subdomain: "global" }
]

tenants.each do |tenant_data|
  tenant = Tenant.find_or_create_by!(subdomain: tenant_data[:subdomain]) do |t|
    t.name = tenant_data[:name]
  end
  
  puts "Created/Found tenant: #{tenant.name} (#{tenant.subdomain})"
end

puts "Seeding completed!"
puts "You can now access tenants at:"
tenants.each do |tenant_data|
  puts "  - http://#{tenant_data[:subdomain]}.localhost:3000"
end
