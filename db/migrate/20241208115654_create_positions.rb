class CreatePositions < ActiveRecord::Migration[7.2]
  def change
    create_table :positions do |t|
      t.string :title
      t.text :description
      t.boolean :is_active
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
