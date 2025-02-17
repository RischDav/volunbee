class AddOnlineToPositions < ActiveRecord::Migration[7.2]
  def change
    add_column :positions, :online, :boolean
  end
end
