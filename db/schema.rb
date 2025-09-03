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

ActiveRecord::Schema[7.1].define(version: 2025_09_03_134805) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "daily_lists", force: :cascade do |t|
    t.date "date", null: false
    t.string "list_type", null: false
    t.integer "sequence_number", default: 1, null: false
    t.string "status", default: "open", null: false
    t.integer "max_players", default: 5, null: false
    t.string "created_by", default: "system"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "list_type", "sequence_number"], name: "idx_daily_lists_unique", unique: true
    t.index ["date", "list_type", "status"], name: "idx_daily_lists_search"
  end

  create_table "presences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "daily_list_id", null: false
    t.string "position", null: false
    t.string "source", default: "web", null: false
    t.string "status", default: "confirmed", null: false
    t.datetime "confirmed_at", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_list_id", "position"], name: "idx_presences_unique_position", unique: true, where: "((status)::text = 'confirmed'::text)"
    t.index ["daily_list_id", "status"], name: "idx_presences_list_status"
    t.index ["daily_list_id", "user_id"], name: "idx_presences_unique_user", unique: true, where: "((status)::text = 'confirmed'::text)"
    t.index ["daily_list_id"], name: "index_presences_on_daily_list_id"
    t.index ["user_id", "status"], name: "idx_presences_user_status"
    t.index ["user_id"], name: "index_presences_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "nickname", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "rank_medal", null: false
    t.integer "rank_stars", null: false
    t.string "preferred_position"
    t.text "positions", default: "[]"
    t.string "category", null: false
    t.string "role", default: "player"
    t.boolean "active", default: true
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_users_on_category"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name", "phone"], name: "index_users_on_name_and_phone", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "presences", "daily_lists"
  add_foreign_key "presences", "users"
end
