# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_01_050907) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "google_calendar_configs", force: :cascade do |t|
    t.hstore "authorization"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_google_calendar_configs_on_user_id"
  end

  create_table "google_calendars", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "description"
    t.string "remote_id"
    t.index ["user_id"], name: "index_google_calendars_on_user_id"
  end

  create_table "google_events", force: :cascade do |t|
    t.string "remote_id"
    t.bigint "event_id", null: false
    t.bigint "google_calendar_id", null: false
    t.index ["event_id"], name: "index_google_events_on_event_id"
    t.index ["google_calendar_id"], name: "index_google_events_on_google_calendar_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "events", "users"
  add_foreign_key "google_calendar_configs", "users"
  add_foreign_key "google_calendars", "users"
  add_foreign_key "google_events", "events"
  add_foreign_key "google_events", "google_calendars"
end
