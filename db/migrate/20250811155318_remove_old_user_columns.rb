class RemoveOldUserColumns < ActiveRecord::Migration[8.0]
  def change
    # Entferne die alten Spalten aus der users Tabelle
    remove_column :users, :organization_id, :integer
    remove_column :users, :university_id, :integer 
    remove_column :users, :role, :integer
    
    # Entferne auch den Index
    remove_index :users, :organization_id if index_exists?(:users, :organization_id)
  end
end
