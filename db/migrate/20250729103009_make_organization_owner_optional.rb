class MakeOrganizationOwnerOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organizations, :owner_id, true
  end
end
