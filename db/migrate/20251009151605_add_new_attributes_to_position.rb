class AddNewAttributesToPosition < ActiveRecord::Migration[8.0]
  def change
    # Add columns with safe defaults to avoid null violations during backfill
    add_column :positions, :type, :integer, null: false, default: 1
    add_column :positions, :appointment, :string

    # Optional: an index on type for filtering
    add_index :positions, :type

    # Add a CHECK constraint to ensure only 1,2,3 are allowed (Rails DSL)
    add_check_constraint :positions, "type IN (1, 2, 3)", name: "positions_type_in_range"
  end
end
