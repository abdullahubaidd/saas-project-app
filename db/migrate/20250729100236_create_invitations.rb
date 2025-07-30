class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations do |t|
      t.string :email, null: false
      t.integer :organization_id, null: false
      t.string :role, null: false, default: 'member'
      t.string :token, null: false
      t.string :status, null: false, default: 'pending'
      t.integer :invited_by_id, null: false
      t.datetime :expires_at, null: false
      t.integer :tenant_id, null: false

      t.timestamps
    end
    
    add_index :invitations, :token, unique: true
    add_index :invitations, [:organization_id, :email], unique: true
    add_foreign_key :invitations, :organizations
    add_foreign_key :invitations, :users, column: :invited_by_id
    add_foreign_key :invitations, :tenants
  end
end
