class AddFreetimeFieldsToPositions < ActiveRecord::Migration[8.0]
  def change
    add_column :positions, :activity_type, :string
    add_column :positions, :location, :string
    add_column :positions, :schedule, :text
  end
end
