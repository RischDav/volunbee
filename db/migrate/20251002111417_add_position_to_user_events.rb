class AddPositionToUserEvents < ActiveRecord::Migration[8.0]
  def change
    add_reference :user_events, :position, foreign_key: true
  end
end
