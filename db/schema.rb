# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_04_141537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "trackable_type"
    t.uuid "trackable_id"
    t.string "owner_type"
    t.uuid "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.uuid "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "defects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description"
    t.string "contact_name"
    t.string "contact_email_address"
    t.string "contact_phone_number"
    t.string "trade"
    t.date "target_completion_date"
    t.integer "status", default: 0
    t.string "reference_number", null: false
    t.uuid "property_id"
    t.uuid "priority_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority_id"], name: "index_defects_on_priority_id"
    t.index ["property_id"], name: "index_defects_on_property_id"
  end

  create_table "estates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "priorities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "scheme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "days"
    t.index ["scheme_id"], name: "index_priorities_on_scheme_id"
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "core_name"
    t.string "address"
    t.string "postcode"
    t.uuid "scheme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uprn"
    t.index ["scheme_id"], name: "index_properties_on_scheme_id"
    t.index ["uprn"], name: "index_properties_on_uprn", unique: true
  end

  create_table "schemes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "estate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contractor_name"
    t.string "contractor_email_address"
    t.string "employer_agent_name"
    t.string "employer_agent_email_address"
    t.index ["estate_id"], name: "index_schemes_on_estate_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  add_foreign_key "comments", "defects"
  add_foreign_key "comments", "users"
  add_foreign_key "defects", "priorities"
  add_foreign_key "defects", "properties"
  add_foreign_key "priorities", "schemes"
  add_foreign_key "properties", "schemes"
  add_foreign_key "schemes", "estates"
end
