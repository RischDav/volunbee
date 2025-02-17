class AddReleasedToPositions < ActiveRecord::Migration[7.2]
  def change
    add_column :positions, :released, :boolean
  end
end
