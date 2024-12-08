class OrganisationToOrganization < ActiveRecord::Migration[7.2]
  def change
    rename_table :organisations, :organizations
  end
end
