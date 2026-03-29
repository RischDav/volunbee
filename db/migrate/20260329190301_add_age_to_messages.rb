class AddAgeToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :age, :integer
  end
end
