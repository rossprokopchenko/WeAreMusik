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

ActiveRecord::Schema[8.0].define(version: 2025_06_17_171852) do
  create_schema "cover_art_archive"
  create_schema "dbmirror2"
  create_schema "documentation"
  create_schema "event_art_archive"
  create_schema "json_dump"
  create_schema "musicbrainz"
  create_schema "report"
  create_schema "sitemaps"
  create_schema "statistics"
  create_schema "wikidocs"

  # These are extensions that must be enabled in order to support this database
  enable_extension "cube"
  enable_extension "earthdistance"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "unaccent"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "cover_art_presence", ["absent", "present", "darkened"]
  create_enum "edit_note_status", ["deleted", "edited"]
  create_enum "event_art_presence", ["absent", "present", "darkened"]
  create_enum "fluency", ["basic", "intermediate", "advanced", "native"]
  create_enum "oauth_code_challenge_method", ["plain", "S256"]
  create_enum "ratable_entity_type", ["artist", "event", "label", "place", "recording", "release_group", "work"]
  create_enum "taggable_entity_type", ["area", "artist", "event", "instrument", "label", "place", "recording", "release", "release_group", "series", "work"]

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

  create_table "alternative_medium", id: :serial, force: :cascade do |t|
    t.integer "medium", null: false
    t.integer "alternative_release", null: false
    t.string "name"
    t.index ["alternative_release"], name: "alternative_medium_idx_alternative_release"
    t.check_constraint "name::text <> ''::text", name: "alternative_medium_name_check"
  end

  create_table "alternative_medium_track", primary_key: ["alternative_medium", "track"], force: :cascade do |t|
    t.integer "alternative_medium", null: false
    t.integer "track", null: false
    t.integer "alternative_track", null: false
  end

  create_table "alternative_release", id: :serial, force: :cascade do |t|
    t.uuid "gid", null: false
    t.integer "release", null: false
    t.string "name"
    t.integer "artist_credit"
    t.integer "type", null: false
    t.integer "language", null: false
    t.integer "script", null: false
    t.string "comment", limit: 255, default: "", null: false
    t.index ["artist_credit"], name: "alternative_release_idx_artist_credit"
    t.index ["gid"], name: "alternative_release_idx_gid", unique: true
    t.index ["language", "script"], name: "alternative_release_idx_language_script"
    t.index ["name"], name: "alternative_release_idx_name"
    t.index ["release"], name: "alternative_release_idx_release"
    t.check_constraint "name::text <> ''::text", name: "alternative_release_name_check"
  end

  create_table "alternative_release_type", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.integer "parent"
    t.integer "child_order", default: 0, null: false
    t.text "description"
    t.uuid "gid", null: false
  end

  create_table "alternative_track", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "artist_credit"
    t.integer "ref_count", default: 0, null: false
    t.index ["artist_credit"], name: "alternative_track_idx_artist_credit"
    t.index ["name"], name: "alternative_track_idx_name"
    t.check_constraint "name::text <> ''::text AND (name IS NOT NULL OR artist_credit IS NOT NULL)", name: "alternative_track_check"
  end

  create_table "annotation", id: :serial, force: :cascade do |t|
    t.integer "editor", null: false
    t.text "text"
    t.string "changelog", limit: 255
    t.timestamptz "created", default: -> { "now()" }
  end

  create_table "application", id: :serial, force: :cascade do |t|
    t.integer "owner", null: false
    t.text "name", null: false
    t.text "oauth_id", null: false
    t.text "oauth_secret", null: false
    t.text "oauth_redirect_uri"
    t.index ["oauth_id"], name: "application_idx_oauth_id", unique: true
    t.index ["owner"], name: "application_idx_owner"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "liked_tracks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "track_id"], name: "index_liked_tracks_on_user_id_and_track_id", unique: true
    t.index ["user_id"], name: "index_liked_tracks_on_user_id"
  end

  create_table "saved_artists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "artist_id"], name: "index_saved_artists_on_user_id_and_artist_id", unique: true
    t.index ["user_id"], name: "index_saved_artists_on_user_id"
  end

  create_table "saved_releases", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "release_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "release_id"], name: "index_saved_releases_on_user_id_and_release_id", unique: true
    t.index ["user_id"], name: "index_saved_releases_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_social_links", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "platform", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "platform"], name: "index_user_social_links_on_user_id_and_platform", unique: true
    t.index ["user_id"], name: "index_user_social_links_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "username", null: false
    t.string "verification_code"
    t.boolean "verified", default: false, null: false
    t.uuid "gid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["gid"], name: "index_users_on_gid", unique: true
  end

  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "liked_tracks", "users"
  add_foreign_key "saved_artists", "users"
  add_foreign_key "saved_releases", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_social_links", "users"
end
