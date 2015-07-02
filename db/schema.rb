# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150702205115) do

  create_table "answer_variants", force: :cascade do |t|
    t.string   "answer_id",   limit: 255
    t.integer  "question_id", limit: 4
    t.text     "text",        limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "answer_variants", ["question_id"], name: "index_answer_variants_on_question_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.text     "text",         limit: 65535
    t.integer  "test_name_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "questions", ["test_name_id"], name: "index_questions_on_test_name_id", using: :btree

  create_table "right_answers", force: :cascade do |t|
    t.string   "answer_id",   limit: 255
    t.integer  "question_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "right_answers", ["question_id"], name: "index_right_answers_on_question_id", using: :btree

  create_table "test_names", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "load_dir",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "answer_variants", "questions"
  add_foreign_key "questions", "test_names"
  add_foreign_key "right_answers", "questions"
end
