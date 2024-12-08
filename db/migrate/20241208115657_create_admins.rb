class CreateAdmins < ActiveRecord::Migration[7.2]
  def change
    create_table :admins do |t|
      t.string :username
      t.string :email
      t.string :password
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
