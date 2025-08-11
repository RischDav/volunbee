class CreateUserAffiliations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_affiliations do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :organization, null: true, foreign_key: true
      t.references :university, null: true, foreign_key: true
      t.integer :role, null: false, default: 0
      t.timestamps
    end

    # Daten von der alten Struktur migrieren
    reversible do |dir|
      dir.up do
        # Migriere bestehende User-Daten zur neuen Struktur
        execute <<-SQL
          INSERT INTO user_affiliations (user_id, organization_id, university_id, role, created_at, updated_at)
          SELECT 
            id as user_id,
            CASE WHEN organization_id IS NOT NULL THEN organization_id ELSE NULL END as organization_id,
            CASE WHEN university_id IS NOT NULL THEN university_id ELSE NULL END as university_id,
            CASE 
              WHEN role = 1 THEN 1  -- Admin bleibt Admin
              WHEN organization_id IS NOT NULL OR university_id IS NOT NULL THEN 0  -- User mit Org/Uni
              ELSE 1  -- User ohne Org/Uni wird Admin
            END as role,
            datetime('now') as created_at,
            datetime('now') as updated_at
          FROM users;
        SQL
      end

      dir.down do
        # Beim Rollback: Daten zurück in users Tabelle schreiben
        execute <<-SQL
          UPDATE users 
          SET 
            organization_id = (SELECT organization_id FROM user_affiliations WHERE user_affiliations.user_id = users.id),
            university_id = (SELECT university_id FROM user_affiliations WHERE user_affiliations.user_id = users.id),
            role = (SELECT role FROM user_affiliations WHERE user_affiliations.user_id = users.id);
        SQL
      end
    end
  end
end
