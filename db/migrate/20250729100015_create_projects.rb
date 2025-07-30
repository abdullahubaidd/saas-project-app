class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :organization_id, null: false
      t.integer :created_by_id, null: false
      t.integer :tenant_id, null: false
      t.boolean :archived, default: false, null: false

      t.timestamps
    end
    
    add_index :projects, [:organization_id, :slug], unique: true
    add_foreign_key :projects, :organizations
    add_foreign_key :projects, :users, column: :created_by_id
    add_foreign_key :projects, :tenants
  end
end
