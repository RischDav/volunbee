class AddUniversityIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :university_id, :integer
  end
end
