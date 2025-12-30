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

ActiveRecord::Schema[8.1].define(version: 2025_12_30_231342) do
  create_table "delayed_jobs", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "attempts", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "failed_at", precision: nil
    t.text "handler"
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "experiences", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "affiliation"
    t.string "affiliation_link"
    t.datetime "created_at", precision: nil
    t.date "end_date"
    t.string "location"
    t.date "start_date"
    t.text "tasks"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.index ["affiliation_link"], name: "index_experiences_on_affiliation_link"
  end

  create_table "facets", id: :integer, charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", precision: nil
    t.text "value"
    t.index ["slug"], name: "index_facets_on_slug"
  end

  create_table "favorite_things", id: :integer, charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "favorite_id"
    t.string "image_content_type"
    t.string "image_file_name"
    t.integer "image_file_size"
    t.datetime "image_updated_at", precision: nil
    t.string "link"
    t.integer "sort"
    t.string "thing"
    t.datetime "updated_at", precision: nil
    t.index ["favorite_id"], name: "index_favorite_things_on_favorite_id"
  end

  create_table "favorites", id: :integer, charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "favorite_type"
    t.integer "sort"
    t.datetime "updated_at", precision: nil
  end

  create_table "links", id: :integer, charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "icon_content_type"
    t.string "icon_file_name"
    t.integer "icon_file_size"
    t.datetime "icon_updated_at", precision: nil
    t.string "name"
    t.boolean "social_icon"
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.boolean "visible"
    t.index ["social_icon"], name: "index_links_on_social_icon"
    t.index ["visible"], name: "index_links_on_visible"
  end

  create_table "recent_games", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "achievement_desc", size: :medium
    t.string "achievement_name"
    t.datetime "achievement_time"
    t.datetime "created_at", precision: nil
    t.boolean "hidden", default: false
    t.string "image_content_type"
    t.string "image_file_name"
    t.integer "image_file_size"
    t.datetime "image_updated_at", precision: nil
    t.string "name"
    t.string "platform"
    t.integer "release_year"
    t.datetime "started_playing", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "url"
  end

  create_table "tabletop_games", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "bgg_url"
    t.datetime "created_at", precision: nil, null: false
    t.text "expansions"
    t.string "image_content_type"
    t.string "image_file_name"
    t.integer "image_file_size"
    t.datetime "image_updated_at", precision: nil
    t.string "name"
    t.text "other_info"
    t.string "players"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: :integer, charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.boolean "enabled", default: false
    t.string "handle"
    t.string "name"
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", precision: nil
  end
end
