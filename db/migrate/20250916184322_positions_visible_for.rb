class PositionsVisibleFor < ActiveRecord::Migration[8.0]
  def change
    create_table :positions_visible_fors do |t|
      t.references :position, null: false, foreign_key: true
      t.references :university, null: false, foreign_key: true
      t.timestamps 
    end

    add_index :positions_visible_fors, [:position_id, :university_id], unique: true
  end
end