class AddBenefitsToPositions < ActiveRecord::Migration[7.2]
  def change
    add_column :positions, :benefits, :text
  end
end
