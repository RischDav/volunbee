class AddAddressAndWebsiteToOrganizations < ActiveRecord::Migration[7.2]
  def change
    add_column :organizations, :city, :string
    add_column :organizations, :zip, :string
    add_column :organizations, :street, :string
    add_column :organizations, :housenumber, :string
    add_column :organizations, :website, :string
  end
end
