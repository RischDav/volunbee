class CreateUniversities < ActiveRecord::Migration[8.0]
  def change
    create_table :universities do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :contact_number
      t.string :profile_picture
      t.boolean :is_approved
      t.boolean :is_deactivated
      t.string :city
      t.string :zip
      t.string :street
      t.string :housenumber
      t.string :website
      t.text :description
      t.string :instagram_url
      t.string :linkedin_url
      t.boolean :facebook_link
      t.boolean :released
      t.string :organization_code
      t.string :contact_person
      t.string :tiktok_url
      t.string :linktree_url

      t.timestamps
    end
  end
end
