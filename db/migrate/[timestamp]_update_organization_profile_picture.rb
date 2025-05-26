class UpdateOrganizationProfilePicture < ActiveRecord::Migration[7.0]
  def change
    remove_column :organizations, :profile_picture, :string
  end
end