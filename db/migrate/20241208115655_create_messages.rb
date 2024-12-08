class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.string :content
      t.string :sender_email
      t.string :sender_phone
      t.references :position, null: false, foreign_key: true
      t.datetime :sent_at

      t.timestamps
    end
  end
end
