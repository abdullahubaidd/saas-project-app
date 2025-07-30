class CreateProjectAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :project_assignments do |t|
      t.integer :user_id, null: false
      t.integer :project_id, null: false
      t.string :role, null: false, default: 'member'
      t.datetime :assigned_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.integer :tenant_id, null: false

      t.timestamps
    end
    
    add_index :project_assignments, [:user_id, :project_id], unique: true
    add_foreign_key :project_assignments, :users
    add_foreign_key :project_assignments, :projects
    add_foreign_key :project_assignments, :tenants
  end
end
