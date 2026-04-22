class AddSignupFieldsToPositions < ActiveRecord::Migration[8.0]
  def change
    add_column :positions, :has_own_signup_page, :boolean, default: false
    add_column :positions, :signup_page, :string
  end
end