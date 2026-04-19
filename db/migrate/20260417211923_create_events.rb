class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      # Basis-Informationen
      t.string :title, null: false
      t.text :description
      t.text :benefits
      t.string :location
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      
      # Optionale Felder (ähnlich Position)
      t.string :event_type   # z.B. 'workshop', 'social', 'sport', 'culture'
      t.string :contact_person
      t.string :contact_email
      t.string :contact_phone
      t.string :website
      
      # Status & Sichtbarkeit
      t.boolean :released, default: false
      t.boolean :online, default: true
      
      # Bilder (ActiveStorage wird separat behandelt)
      # Organisation/Ersteller
      t.references :organization, foreign_key: true
      t.references :user, foreign_key: true   # Ersteller
      
      # Zeitstempel
      t.timestamps
    end
    
    # Indizes für häufige Abfragen
    add_index :events, [:released, :online]
    add_index :events, :start_date
    add_index :events, :end_date
  end
end