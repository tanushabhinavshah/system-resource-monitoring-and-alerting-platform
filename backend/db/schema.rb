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

ActiveRecord::Schema[8.1].define(version: 2026_02_04_094140) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_resolved", default: false, null: false
    t.text "reason"
    t.string "resource_type"
    t.string "severity"
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
  end

  create_table "cpu_allocations", force: :cascade do |t|
    t.integer "allocated_cores"
    t.datetime "created_at", null: false
    t.string "reason"
    t.integer "total_cores"
    t.datetime "updated_at", null: false
  end

  create_table "metrics", force: :cascade do |t|
    t.float "cpu_usage_percent"
    t.datetime "created_at", null: false
    t.float "memory_usage_percent"
    t.float "network_in_kb"
    t.float "network_out_kb"
    t.datetime "updated_at", null: false
  end

  create_table "thresholds", force: :cascade do |t|
    t.float "cpu_threshold"
    t.datetime "created_at", null: false
    t.float "memory_threshold"
    t.float "network_in_threshold"
    t.float "network_out_threshold"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end
end
