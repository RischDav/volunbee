class AddReleasedToOrganizations < ActiveRecord::Migration[7.2]
  def change
    add_column :organizations, :released, :boolean
  end
end
