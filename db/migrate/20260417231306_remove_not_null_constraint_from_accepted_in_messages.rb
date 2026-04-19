class RemoveNotNullConstraintFromAcceptedInMessages < ActiveRecord::Migration[8.0]
  def change
    change_column_null :messages, :accepted, true
  end
end