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

ActiveRecord::Schema[7.1].define(version: 2024_05_15_121645) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blocks", force: :cascade do |t|
    t.string "name"
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_blocks_on_building_id"
  end

  create_table "buildings", force: :cascade do |t|
    t.string "building_name"
    t.string "building_address"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_buildings_on_user_id"
  end

  create_table "floors", force: :cascade do |t|
    t.integer "number"
    t.bigint "block_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["block_id"], name: "index_floors_on_block_id"
  end

  create_table "maintenance_bills", force: :cascade do |t|
    t.string "bill_name"
    t.string "bill_month_and_year"
    t.decimal "owner_amount"
    t.decimal "rent_amount"
    t.date "start_date"
    t.date "end_date"
    t.text "remarks"
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_maintenance_bills_on_building_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.date "month_year"
    t.string "bill_name"
    t.string "block"
    t.integer "floor"
    t.string "room_number"
    t.decimal "amount"
    t.string "payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "maintenance_bill_id"
    t.integer "status"
    t.bigint "user_id", null: false
    t.bigint "water_bill_id"
    t.index ["maintenance_bill_id"], name: "index_payments_on_maintenance_bill_id"
    t.index ["water_bill_id"], name: "index_payments_on_water_bill_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "room_number"
    t.bigint "floor_id", null: false
    t.bigint "block_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_units"
    t.float "unit_rate"
    t.float "previous_unit"
    t.float "updated_unit"
    t.index ["block_id"], name: "index_rooms_on_block_id"
    t.index ["floor_id"], name: "index_rooms_on_floor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "otp"
    t.string "mobile_number"
    t.bigint "block_id"
    t.bigint "floor_id"
    t.integer "room_number", default: 0
    t.integer "owner_or_renter", default: 0
    t.integer "role", default: 0
    t.bigint "room_id"
    t.string "status", default: "pending"
    t.string "gender"
    t.index ["block_id"], name: "index_users_on_block_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["floor_id"], name: "index_users_on_floor_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "water_bills", force: :cascade do |t|
    t.string "bill_name"
    t.string "bill_month_and_year"
    t.decimal "owner_amount"
    t.decimal "rent_amount"
    t.date "start_date"
    t.date "end_date"
    t.text "remarks"
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_water_bills_on_building_id"
  end

  add_foreign_key "blocks", "buildings"
  add_foreign_key "buildings", "users"
  add_foreign_key "floors", "blocks"
  add_foreign_key "maintenance_bills", "buildings"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "payments", "maintenance_bills"
  add_foreign_key "payments", "water_bills"
  add_foreign_key "rooms", "blocks"
  add_foreign_key "rooms", "floors"
  add_foreign_key "users", "blocks"
  add_foreign_key "users", "floors"
  add_foreign_key "water_bills", "buildings"
end
