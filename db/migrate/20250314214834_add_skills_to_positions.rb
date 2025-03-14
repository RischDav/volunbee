class AddSkillsToPositions < ActiveRecord::Migration[8.0]
  def change
    add_column :positions, :creative_skills, :integer
    add_column :positions, :technical_skills, :integer
    add_column :positions, :social_skills, :integer
    add_column :positions, :language_skills, :integer
    add_column :positions, :flexibility, :integer
  end
end
