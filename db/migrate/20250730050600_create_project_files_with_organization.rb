class CreateProjectFilesWithOrganization < ActiveRecord::Migration[8.0]
  def change
    create_table :project_files do |t|
      t.references :project, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.references :organization, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
    
    add_index :project_files, [:organization_id, :project_id]
  end
end
