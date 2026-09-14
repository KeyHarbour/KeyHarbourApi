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

ActiveRecord::Schema[8.1].define(version: 2026_06_19_120636) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_logs", force: :cascade do |t|
    t.string "action"
    t.bigint "action_id"
    t.string "controller"
    t.datetime "created_at", null: false
    t.string "method_type"
    t.bigint "organization_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
  end

  create_table "api_queries", force: :cascade do |t|
    t.string "action", null: false
    t.string "controller", null: false
    t.datetime "created_at", null: false
    t.datetime "date", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "service_name"
    t.bigint "serviceable_id", null: false
    t.string "serviceable_type", null: false
    t.integer "token"
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_api_queries_on_date"
    t.index ["service_name"], name: "index_api_queries_on_service_name"
  end
end
