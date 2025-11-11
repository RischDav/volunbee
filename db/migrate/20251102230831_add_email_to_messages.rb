class AddEmailToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :email, :string
  end
end
