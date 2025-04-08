class DropAdminTable < ActiveRecord::Migration[7.0] # Adjust version if needed
  def up
    drop_table :admins
  end

  def down
    create_table :admins do |t|
      t.string :name
      t.string :email
      # Add any other columns that were in the original table

      t.timestamps
    end
  end
end