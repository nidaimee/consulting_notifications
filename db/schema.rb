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

ActiveRecord::Schema[8.0].define(version: 2025_09_09_143428) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "last_contacted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.date "start_date"
    t.decimal "paid_amount"
    t.date "end_date"
    t.text "note"
    t.bigint "user_id", null: false
    t.string "status", default: "active", null: false
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "diet_foods", force: :cascade do |t|
    t.bigint "diet_id", null: false
    t.bigint "food_id", null: false
    t.decimal "quantity_grams"
    t.decimal "calories"
    t.decimal "protein"
    t.decimal "carbs"
    t.decimal "fat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diet_id"], name: "index_diet_foods_on_diet_id"
    t.index ["food_id"], name: "index_diet_foods_on_food_id"
  end

  create_table "diets", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "name"
    t.string "meal_type"
    t.text "notes"
    t.date "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["client_id"], name: "index_diets_on_client_id"
    t.index ["user_id"], name: "index_diets_on_user_id"
  end

  create_table "foods", force: :cascade do |t|
    t.string "name"
    t.decimal "calories_per_100g"
    t.decimal "protein_per_100g"
    t.decimal "carbs_per_100g"
    t.decimal "fat_per_100g"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_foods_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "phone"
    t.string "specialty"
    t.string "license_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "clients", "users"
  add_foreign_key "diet_foods", "diets"
  add_foreign_key "diet_foods", "foods"
  add_foreign_key "diets", "clients"
  add_foreign_key "diets", "users"
  add_foreign_key "foods", "users"
end
