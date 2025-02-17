class ChangeReleasedDefaultInPositions < ActiveRecord::Migration[7.2]
  def change
    change_column_default :positions, :released, from: nil, to: false
  end
end
