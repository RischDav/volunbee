class AddCounterCachesToOrganizationsAndUniversities < ActiveRecord::Migration[8.0]
  def change
    # Add counter cache columns
    add_column :organizations, :positions_count, :integer, default: 0, null: false
    add_column :universities, :positions_count, :integer, default: 0, null: false
    
    # Backfill existing counts
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE organizations
          SET positions_count = (
            SELECT COUNT(*) FROM positions WHERE positions.organization_id = organizations.id
          )
        SQL
        
        execute <<-SQL.squish
          UPDATE universities
          SET positions_count = (
            SELECT COUNT(*) FROM positions WHERE positions.university_id = universities.id
          )
        SQL
      end
    end
  end
end
