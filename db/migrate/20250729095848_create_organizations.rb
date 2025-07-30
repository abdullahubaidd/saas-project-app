class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :owner_id, null: false
      t.integer :tenant_id, null: false

      t.timestamps
    end
    
    add_index :organizations, [:tenant_id, :slug], unique: true
    add_foreign_key :organizations, :users, column: :owner_id
    add_foreign_key :organizations, :tenants
  end
end
