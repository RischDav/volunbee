class ChangeReleasedDefaultInOrganizations < ActiveRecord::Migration[7.2]
  def change
    change_column_default :organizations, :released, from: nil, to: false
  end
end
