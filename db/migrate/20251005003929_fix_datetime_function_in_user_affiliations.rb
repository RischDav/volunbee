class FixDatetimeFunctionInUserAffiliations < ActiveRecord::Migration[8.0]
  def up
    # Lösche vorhandene Einträge
    UserAffiliation.delete_all
    
    # Umgehe Validierungen mit insert_all (Rails 6+)
    users_data = User.all.map do |user|
      {
        user_id: user.id,
        organization_id: nil,
        university_id: nil,
        role: 1, # Setze alle als Admin, da sie keine Org/Uni haben
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    
    UserAffiliation.insert_all(users_data) if users_data.any?
  end

  def down
    UserAffiliation.delete_all
  end
end