class AddColumnsToPositions < ActiveRecord::Migration[8.0]
  def change
    add_column :positions, :position_temporary, :boolean
    add_column :positions, :weekly_time_commitment, :integer
    add_column :positions, :position_code, :string
  end
end
