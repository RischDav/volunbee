class MakeOrganizationIdOptionalInPositions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :positions, :organization_id, true
  end
end
