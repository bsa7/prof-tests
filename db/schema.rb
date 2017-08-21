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

ActiveRecord::Schema.define(version: 20150703020900) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answer_variants", id: :serial, force: :cascade do |t|
    t.string "answer_id"
    t.integer "question_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answer_variants_on_question_id"
  end

  create_table "client_answers", id: :serial, force: :cascade do |t|
    t.string "client_shortcut_id"
    t.string "session_shortcut_id"
    t.integer "question_id"
    t.string "answer_id"
    t.boolean "is_right"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_client_answers_on_question_id"
  end

  create_table "client_shortcuts", id: :serial, force: :cascade do |t|
    t.string "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip"
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "client_id"
    t.string "nick"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.text "text"
    t.integer "test_name_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_name_id"], name: "index_questions_on_test_name_id"
  end

  create_table "right_answers", id: :serial, force: :cascade do |t|
    t.string "answer_id"
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_right_answers_on_question_id"
  end

  create_table "session_shortcuts", id: :serial, force: :cascade do |t|
    t.string "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_names", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "load_dir"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "answer_variants", "questions"
  add_foreign_key "client_answers", "questions"
  add_foreign_key "questions", "test_names"
  add_foreign_key "right_answers", "questions"
end
