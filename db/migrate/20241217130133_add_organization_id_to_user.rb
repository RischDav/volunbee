class AddOrganizationIdToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :organization_id, :integer
    add_index :users, :organization_id
  end
end
