class CreateOrganizations < ActiveRecord::Migration[7.2]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :contact_number
      t.string :profile_picture
      t.boolean :is_approved
      t.boolean :is_deactivated

      t.timestamps
    end
  end
end
