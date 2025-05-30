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

ActiveRecord::Schema[8.0].define(version: 2025_05_21_171802) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "artist", id: :integer, default: nil, force: :cascade do |t|
    t.uuid "gid", null: false
    t.text "name", null: false
    t.text "sort_name", null: false
    t.integer "begin_date_year", limit: 2
    t.integer "begin_date_month", limit: 2
    t.integer "begin_date_day", limit: 2
    t.integer "end_date_year", limit: 2
    t.integer "end_date_month", limit: 2
    t.integer "end_date_day", limit: 2
    t.integer "type"
    t.integer "area"
    t.integer "gender"
    t.text "comment", default: "", null: false
    t.integer "edits_pending", default: 0, null: false
    t.datetime "last_updated", precision: nil
    t.boolean "ended", default: false, null: false
    t.integer "extra_metric_1"
    t.integer "extra_metric_2"
  end

  create_table "artist_credit", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 1024, null: false
    t.integer "artist_count", null: false
    t.integer "ref_count", null: false
    t.timestamptz "created", null: false
    t.integer "edits_pending", default: 0, null: false
    t.uuid "gid", null: false

    t.unique_constraint ["gid"], name: "artist_credit_gid_key"
  end

  create_table "artist_credit_name", primary_key: ["artist_credit", "position"], force: :cascade do |t|
    t.integer "artist_credit", null: false
    t.integer "position", null: false
    t.integer "artist", null: false
    t.string "name", limit: 1024, null: false
    t.string "join_phrase", limit: 255, null: false
  end

  create_table "genre", id: :integer, default: nil, force: :cascade do |t|
    t.uuid "gid", null: false
    t.text "name", null: false
    t.text "comment", null: false
    t.integer "edits_pending", default: 0, null: false
    t.datetime "last_updated", precision: nil
  end

  create_table "medium", id: :integer, default: nil, force: :cascade do |t|
    t.integer "release", null: false
    t.integer "position", null: false
    t.integer "format"
    t.string "name", limit: 1024
    t.integer "edits_pending", default: 0, null: false
    t.timestamptz "last_updated"
    t.integer "track_count"
    t.text "gid"
  end

  create_table "recording", id: :integer, default: nil, force: :cascade do |t|
    t.uuid "gid", null: false
    t.text "name", null: false
    t.integer "artist_credit", null: false
    t.integer "length"
    t.text "comment"
    t.integer "edits_pending", default: 0, null: false
    t.datetime "last_updated", precision: nil
    t.boolean "video", default: false, null: false
  end

  create_table "release", id: :integer, default: nil, force: :cascade do |t|
    t.uuid "gid", null: false
    t.text "name", null: false
    t.integer "artist_credit", null: false
    t.integer "release_group", null: false
    t.integer "status"
    t.integer "packaging"
    t.integer "language"
    t.integer "script"
    t.text "barcode"
    t.text "comment"
    t.integer "edits_pending", default: 0, null: false
    t.integer "quality"
    t.datetime "last_updated", precision: nil
  end

  create_table "release_group", id: :integer, default: nil, force: :cascade do |t|
    t.uuid "gid", null: false
    t.string "name", limit: 1024, null: false
    t.integer "artist_credit", null: false
    t.integer "type"
    t.string "comment", limit: 1024
    t.integer "edits_pending", default: 0, null: false
    t.timestamptz "last_updated"

    t.unique_constraint ["gid"], name: "release_group_gid_key"
  end

  create_table "release_group_primary_type", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.integer "parent"
    t.integer "child_order", default: 0, null: false
    t.text "description"
    t.uuid "gid", null: false

    t.unique_constraint ["gid"], name: "release_group_primary_type_gid_key"
    t.unique_constraint ["name"], name: "release_group_primary_type_name_key"
  end

  create_table "release_status", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.integer "parent"
    t.integer "child_order", default: 0, null: false
    t.text "description"
    t.uuid "gid", null: false

    t.unique_constraint ["gid"], name: "release_status_gid_key"
    t.unique_constraint ["name"], name: "release_status_name_key"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "track", id: :integer, default: nil, force: :cascade do |t|
    t.uuid "gid", null: false
    t.integer "recording", null: false
    t.integer "medium", null: false
    t.integer "position", null: false
    t.text "number", null: false
    t.text "name", null: false
    t.integer "artist_credit", null: false
    t.integer "length"
    t.integer "edits_pending", default: 0, null: false
    t.datetime "last_updated", precision: nil
    t.boolean "is_data_track"
    t.tsvector "search_vector"
    t.index ["search_vector"], name: "index_track_on_search_vector", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "release_group_primary_type", "release_group_primary_type", column: "parent", name: "release_group_primary_type_parent_fkey"
  add_foreign_key "release_status", "release_status", column: "parent", name: "release_status_parent_fkey"
  add_foreign_key "sessions", "users"
end
