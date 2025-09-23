class AddUserIdToPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :positions, :user_id, :bigint
    add_index :positions, :user_id
    add_foreign_key :positions, :users
  end
end
