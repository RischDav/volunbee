class UpdateMessagesTableForApplications < ActiveRecord::Migration[8.0]
  def change
    # Remove old fields
    remove_column :messages, :content, :string
    remove_column :messages, :sender_email, :string
    
    # Make existing fields optional
    change_column_null :messages, :sender_phone, true
    change_column_null :messages, :sent_at, true
    
    # Add user_id as required reference
    add_reference :messages, :user, null: false, foreign_key: true
    
    # Add application type
    add_column :messages, :type, :string, null: false
    
    # Personal Information fields (from all forms)
    add_column :messages, :first_name, :string
    add_column :messages, :last_name, :string
    add_column :messages, :birth_date, :date
    add_column :messages, :phone_number, :string
    add_column :messages, :gender, :string
    
    # Experience fields (from assistant and volunteer forms)
    add_column :messages, :has_experience, :string
    add_column :messages, :experience_description, :text
    add_column :messages, :has_volunteer_experience, :string
    add_column :messages, :volunteer_experience_description, :text
    
    # Motivation/About fields (from all forms)
    add_column :messages, :motivation, :text
    add_column :messages, :about_yourself, :text
    
    # Add indexes for better performance
    add_index :messages, :type
    add_index :messages, [:type, :position_id]
  end
end