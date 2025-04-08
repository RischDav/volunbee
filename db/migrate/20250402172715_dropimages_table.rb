class DropimagesTable < ActiveRecord::Migration[7.0] # Adjust version if needed
  def up
    drop_table :images
  end

  def down
    create_table :images do |t|
      t.string :name
      t.string :email
      # Add any other columns that were in the original table

      t.timestamps
    end
  end
end
