class AddDetailsToOrganizations < ActiveRecord::Migration[7.2]
  def change
    add_column :organizations, :description, :text
    add_column :organizations, :instagram_url, :string
    add_column :organizations, :linkedin_url, :string
    add_column :organizations, :facebook_link, :string
  end
end
