class AddVisibilityToPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :positions, :visibility, :string, default: "all", null: false
    add_reference :positions, :visible_university, foreign_key: { to_table: :universities }, null: true
  end
end
