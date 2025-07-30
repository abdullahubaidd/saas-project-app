class CreateOrganizationMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_memberships do |t|
      t.integer :user_id, null: false
      t.integer :organization_id, null: false
      t.string :role, null: false, default: 'member'
      t.integer :tenant_id, null: false

      t.timestamps
    end
    
    add_index :organization_memberships, [:user_id, :organization_id], unique: true
    add_foreign_key :organization_memberships, :users
    add_foreign_key :organization_memberships, :organizations
    add_foreign_key :organization_memberships, :tenants
  end
end
