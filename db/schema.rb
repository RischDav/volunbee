# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_09_152352) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "frequently_asked_questions", force: :cascade do |t|
    t.string "question"
    t.text "answer"
    t.bigint "position_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position_id"], name: "index_frequently_asked_questions_on_position_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "content"
    t.string "sender_email"
    t.string "sender_phone"
    t.bigint "position_id", null: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position_id"], name: "index_messages_on_position_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password"
    t.string "contact_number"
    t.string "profile_picture"
    t.boolean "is_approved"
    t.boolean "is_deactivated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city"
    t.string "zip"
    t.string "street"
    t.string "housenumber"
    t.string "website"
    t.text "description"
    t.string "instagram_url"
    t.string "linkedin_url"
    t.string "facebook_link"
    t.boolean "released", default: false
    t.string "organization_code", default: ""
    t.string "contact_person", default: ""
    t.string "tiktok_url", default: ""
    t.string "linktree_url", default: ""
  end

  create_table "positions", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "is_active"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "benefits"
    t.integer "creative_skills"
    t.integer "technical_skills"
    t.integer "social_skills"
    t.integer "language_skills"
    t.integer "flexibility"
    t.boolean "released", default: false
    t.boolean "online"
    t.boolean "position_temporary"
    t.integer "weekly_time_commitment"
    t.string "position_code"
    t.integer "university_id"
    t.bigint "user_id"
    t.string "visibility", default: "all", null: false
    t.integer "visible_university_id"
    t.integer "type", default: 1, null: false
    t.string "appointment"
    t.string "payment"
    t.index ["organization_id"], name: "index_positions_on_organization_id"
    t.index ["type"], name: "index_positions_on_type"
    t.index ["user_id"], name: "index_positions_on_user_id"
    t.index ["visible_university_id"], name: "index_positions_on_visible_university_id"
    t.check_constraint "type IN (1, 2, 3)", name: "positions_type_in_range"
  end

  create_table "positions_visible_fors", force: :cascade do |t|
    t.integer "position_id", null: false
    t.integer "university_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position_id", "university_id"], name: "index_positions_visible_fors_on_position_id_and_university_id", unique: true
    t.index ["position_id"], name: "index_positions_visible_fors_on_position_id"
    t.index ["university_id"], name: "index_positions_visible_fors_on_university_id"
  end

  create_table "universities", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password"
    t.string "contact_number"
    t.string "profile_picture"
    t.boolean "is_approved"
    t.boolean "is_deactivated"
    t.string "city"
    t.string "zip"
    t.string "street"
    t.string "housenumber"
    t.string "website"
    t.text "description"
    t.string "instagram_url"
    t.string "linkedin_url"
    t.boolean "facebook_link"
    t.boolean "released"
    t.string "organization_code"
    t.string "contact_person"
    t.string "tiktok_url"
    t.string "linktree_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_affiliations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "organization_id"
    t.integer "university_id"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_user_affiliations_on_organization_id"
    t.index ["university_id"], name: "index_user_affiliations_on_university_id"
    t.index ["user_id"], name: "index_user_affiliations_on_user_id", unique: true
  end

  create_table "user_events", force: :cascade do |t|
    t.integer "university_id"
    t.integer "action_type", null: false
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_type", default: 0, null: false
    t.integer "position_id"
    t.index ["organization_id"], name: "index_user_events_on_organization_id"
    t.index ["position_id"], name: "index_user_events_on_position_id"
    t.index ["university_id"], name: "index_user_events_on_university_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "released", default: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "frequently_asked_questions", "positions"
  add_foreign_key "messages", "positions"
  add_foreign_key "positions", "organizations"
  add_foreign_key "positions", "universities", column: "visible_university_id"
  add_foreign_key "positions", "users"
  add_foreign_key "positions_visible_fors", "positions"
  add_foreign_key "positions_visible_fors", "universities"
  add_foreign_key "user_affiliations", "organizations"
  add_foreign_key "user_affiliations", "universities"
  add_foreign_key "user_affiliations", "users"
  add_foreign_key "user_events", "organizations"
  add_foreign_key "user_events", "positions"
  add_foreign_key "user_events", "universities"
end
