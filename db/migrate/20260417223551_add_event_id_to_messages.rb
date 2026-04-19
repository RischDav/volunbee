class AddEventIdToMessages < ActiveRecord::Migration[8.0]
  def change
    add_reference :messages, :event, foreign_key: true, null: true
  end
end