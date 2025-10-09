class ChangeColumnsInUserEvents < ActiveRecord::Migration[8.0]
  def change
    change_column_null :user_events, :university_id, true
    change_column_null :user_events, :organization_id, true
    remove_column :user_events, :user_type, :string
    add_column :user_events, :user_type, :integer, null: false, default: 0
  end
end
