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

ActiveRecord::Schema[8.1].define(version: 2026_01_29_155359) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "concepts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "datagraphs_id"
    t.text "datagraphs_type"
    t.text "label"
    t.jsonb "properties"
    t.datetime "updated_at", null: false
    t.index ["datagraphs_id"], name: "index_concepts_on_datagraphs_id"
  end

  create_table "datasets", force: :cascade do |t|
    t.text "concept_types", array: true
    t.datetime "created_at", null: false
    t.text "datagraphs_id"
    t.boolean "is_private"
    t.text "link_to_self"
    t.text "name"
    t.text "namespace"
    t.integer "total_concepts"
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_in"
    t.text "token"
    t.datetime "updated_at", null: false
  end
end
