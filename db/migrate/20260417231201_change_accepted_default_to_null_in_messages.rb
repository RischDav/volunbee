class ChangeAcceptedDefaultToNullInMessages < ActiveRecord::Migration[8.0]
  def change
    change_column_default :messages, :accepted, nil
  end
end