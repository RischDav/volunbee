class AddPreferredLanguageToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :preferred_language, :string
  end
end
