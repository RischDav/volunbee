class CreateUserAffiliations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_affiliations do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :organization, null: true, foreign_key: true
      t.references :university, null: true, foreign_key: true
      t.integer :role, null: false, default: 0
      t.timestamps
    end

    # Verwende ActiveRecord statt rohem SQL (datenbankunabhängig)
    reversible do |dir|
      dir.up do
        User.find_each do |user|
          # Bestimme die Rolle basierend auf vorhandenen Daten
          role = if user.role == 1
                   1 # Admin bleibt Admin
                 elsif user.organization_id.present? || user.university_id.present?
                   0 # User mit Organisation/Universität
                 else
                   1 # User ohne wird Admin
                 end
          
          UserAffiliation.create!(
            user_id: user.id,
            organization_id: user.organization_id,
            university_id: user.university_id,
            role: role
            # created_at und updated_at werden automatisch gesetzt!
          )
        end
      end

      dir.down do
        UserAffiliation.find_each do |affiliation|
          user = User.find(affiliation.user_id)
          user.update!(
            organization_id: affiliation.organization_id,
            university_id: affiliation.university_id,
            role: affiliation.role
          )
        end
      end
    end
  end
end