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

ActiveRecord::Schema[8.1].define(version: 2026_08_01_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "choices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "movie_id", null: false
    t.integer "ranking"
    t.boolean "selected"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_choices_on_event_id"
    t.index ["movie_id"], name: "index_choices_on_movie_id"
    t.index ["user_id"], name: "index_choices_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "venue", default: "indoor", null: false
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.datetime "expires_at"
    t.string "label"
    t.integer "max_uses"
    t.datetime "revoked_at"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "uses_count", default: 0, null: false
    t.index ["created_by_id"], name: "index_invitations_on_created_by_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "director"
    t.string "kind"
    t.string "overview"
    t.string "poster_url"
    t.string "title"
    t.integer "tmdb_id"
    t.string "trailer_url"
    t.datetime "updated_at", null: false
    t.date "year"
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "choice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["choice_id"], name: "index_votes_on_choice_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "choices", "events"
  add_foreign_key "choices", "movies"
  add_foreign_key "choices", "users"
  add_foreign_key "invitations", "users", column: "created_by_id"
  add_foreign_key "votes", "choices"
  add_foreign_key "votes", "users"
end
