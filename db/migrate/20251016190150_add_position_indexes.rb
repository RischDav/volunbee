class AddPositionIndexes < ActiveRecord::Migration[8.0]
  def change
    # Composite indexes for common queries
    add_index :positions, [:released, :online], name: 'index_positions_on_released_and_online'
    add_index :positions, [:organization_id, :released], name: 'index_positions_on_org_and_released'
    add_index :positions, [:university_id, :visibility], name: 'index_positions_on_uni_and_visibility'
    add_index :positions, [:type, :online, :released], name: 'index_positions_on_type_online_released'
    
    # Individual indexes for filtering
    add_index :positions, :visibility unless index_exists?(:positions, :visibility)
  end
end
