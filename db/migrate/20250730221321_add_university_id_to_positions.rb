class AddUniversityIdToPositions < ActiveRecord::Migration[8.0]
  def change
    add_column :positions, :university_id, :integer
  end
end
