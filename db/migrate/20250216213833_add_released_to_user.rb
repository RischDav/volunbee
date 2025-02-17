class AddReleasedToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :released, :boolean
  end
end
