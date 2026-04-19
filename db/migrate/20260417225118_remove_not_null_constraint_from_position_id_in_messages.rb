class RemoveNotNullConstraintFromPositionIdInMessages < ActiveRecord::Migration[8.0]
  def change
    change_column_null :messages, :position_id, true
  end
end