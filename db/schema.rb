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

ActiveRecord::Schema.define(version: 2022_06_06_172129) do

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

  create_table "comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "message"
    t.uuid "user_id"
    t.uuid "defect_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["defect_id"], name: "index_comments_on_defect_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "communal_areas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "scheme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
    t.index ["scheme_id"], name: "index_communal_areas_on_scheme_id"
  end

  create_table "defects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description"
    t.string "contact_name"
    t.string "contact_email_address"
    t.string "contact_phone_number"
    t.string "trade"
    t.date "target_completion_date"
    t.integer "status", default: 0
    t.uuid "property_id"
    t.uuid "priority_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "access_information"
    t.boolean "communal", default: false
    t.uuid "communal_area_id"
    t.serial "sequence_number", null: false
    t.boolean "flagged", default: false, null: false
    t.date "actual_completion_date"
    t.datetime "added_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["communal_area_id"], name: "index_defects_on_communal_area_id"
    t.index ["priority_id"], name: "index_defects_on_priority_id"
    t.index ["property_id"], name: "index_defects_on_property_id"
    t.index ["sequence_number"], name: "index_defects_on_sequence_number", unique: true
  end

  create_table "estates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "evidences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "description"
    t.uuid "defect_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.string "supporting_file"
    t.index ["defect_id"], name: "index_evidences_on_defect_id"
    t.index ["user_id"], name: "index_evidences_on_user_id"
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
    t.date "start_date"
    t.string "project_manager_name"
    t.string "project_manager_email_address"
    t.string "employer_agent_phone_number"
    t.index ["estate_id"], name: "index_schemes_on_estate_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  add_foreign_key "comments", "defects"
  add_foreign_key "comments", "users"
  add_foreign_key "communal_areas", "schemes"
  add_foreign_key "defects", "priorities"
  add_foreign_key "defects", "properties"
  add_foreign_key "evidences", "defects"
  add_foreign_key "evidences", "users"
  add_foreign_key "priorities", "schemes"
  add_foreign_key "properties", "schemes"
  add_foreign_key "schemes", "estates"
end
