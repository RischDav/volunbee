class ChangeReleasedDefaultInUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :released, from: nil, to: false
  end
end