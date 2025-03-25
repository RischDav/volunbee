class AddColumnsToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :organization_code, :string, default: ""
    add_column :organizations, :contact_person, :string, default: ""
    add_column :organizations, :tiktok_url, :string, default: ""
    add_column :organizations, :linktree_url, :string, default: ""
  end
end
