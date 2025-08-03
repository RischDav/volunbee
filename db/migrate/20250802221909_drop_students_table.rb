class DropStudentsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :students do |t|
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "name"
      t.string "last_name"
      t.string "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string "unconfirmed_email"
      t.integer "university_id", null: false
      t.index ["email"], name: "index_students_on_email", unique: true
      t.index ["reset_password_token"], name: "index_students_on_reset_password_token", unique: true
      t.index ["university_id"], name: "index_students_on_university_id"
    end
  end
end