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

ActiveRecord::Schema[7.1].define(version: 2024_11_28_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "daily_lists", force: :cascade do |t|
    t.date "date", null: false
    t.string "status", default: "generated"
    t.text "content"
    t.json "summary", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_daily_lists_on_date", unique: true
    t.index ["status"], name: "index_daily_lists_on_status"
  end

  create_table "presences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "daily_list_id", null: false
    t.string "position", null: false
    t.string "source", default: "web"
    t.datetime "confirmed_at"
    t.string "status", default: "confirmed"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_list_id", "position"], name: "index_presences_on_daily_list_id_and_position", unique: true
    t.index ["daily_list_id", "user_id"], name: "index_presences_on_daily_list_id_and_user_id", unique: true
    t.index ["daily_list_id"], name: "index_presences_on_daily_list_id"
    t.index ["source"], name: "index_presences_on_source"
    t.index ["status"], name: "index_presences_on_status"
    t.index ["user_id"], name: "index_presences_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "nickname", null: false
    t.string "phone"
    t.string "category", null: false
    t.json "positions", default: []
    t.string "preferred_position"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["category"], name: "index_users_on_category"
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  create_table "whatsapp_messages", force: :cascade do |t|
    t.string "phone", null: false
    t.text "content", null: false
    t.string "status", default: "pending"
    t.bigint "user_id"
    t.bigint "presence_id"
    t.text "error_message"
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_whatsapp_messages_on_phone"
    t.index ["presence_id"], name: "index_whatsapp_messages_on_presence_id"
    t.index ["received_at"], name: "index_whatsapp_messages_on_received_at"
    t.index ["status"], name: "index_whatsapp_messages_on_status"
    t.index ["user_id"], name: "index_whatsapp_messages_on_user_id"
  end

  add_foreign_key "presences", "daily_lists"
  add_foreign_key "presences", "users"
  add_foreign_key "whatsapp_messages", "presences"
  add_foreign_key "whatsapp_messages", "users"
end
