class RefactorToOrganizationAsTenant < ActiveRecord::Migration[8.0]
  def up
    # Add subdomain to organizations table
    add_column :organizations, :subdomain, :string
    add_index :organizations, :subdomain, unique: true
    
    # Remove tenant_id from all tables and replace with organization_id where needed
    remove_foreign_key :users, :tenants
    remove_column :users, :tenant_id
    add_column :users, :organization_id, :integer
    add_foreign_key :users, :organizations
    add_index :users, :organization_id
    
    # Update other tables
    remove_foreign_key :organizations, :tenants
    remove_column :organizations, :tenant_id
    
    remove_foreign_key :organization_memberships, :tenants
    remove_column :organization_memberships, :tenant_id
    
    remove_foreign_key :projects, :tenants
    remove_column :projects, :tenant_id
    
    remove_foreign_key :project_assignments, :tenants
    remove_column :project_assignments, :tenant_id
    
    remove_foreign_key :invitations, :tenants
    remove_column :invitations, :tenant_id
    
    # Drop the tenants table
    drop_table :tenants
  end
  
  def down
    # Recreate tenants table
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.timestamps
    end
    add_index :tenants, :subdomain, unique: true
    
    # Add tenant_id back to all tables
    add_column :users, :tenant_id, :integer
    add_foreign_key :users, :tenants
    remove_foreign_key :users, :organizations
    remove_column :users, :organization_id
    
    add_column :organizations, :tenant_id, :integer
    add_foreign_key :organizations, :tenants
    remove_column :organizations, :subdomain
    
    add_column :organization_memberships, :tenant_id, :integer
    add_foreign_key :organization_memberships, :tenants
    
    add_column :projects, :tenant_id, :integer
    add_foreign_key :projects, :tenants
    
    add_column :project_assignments, :tenant_id, :integer
    add_foreign_key :project_assignments, :tenants
    
    add_column :invitations, :tenant_id, :integer
    add_foreign_key :invitations, :tenants
  end
end
