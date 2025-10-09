class CreateUserEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :user_events do |t|
      t.string :user_type
      t.references :university, null: false, foreign_key: true
      t.integer :action_type, null: false
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
