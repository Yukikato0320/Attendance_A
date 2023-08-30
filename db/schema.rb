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

ActiveRecord::Schema.define(version: 20230801165731) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at_before"
    t.datetime "finished_at_before"
    t.datetime "started_at_edited"
    t.datetime "finished_at_edited"
    t.datetime "estimated_overtime_hours"
    t.string "business_process_content"
    t.boolean "next_day_overtime"
    t.boolean "next_day_working_hours"
    t.integer "selector_overtime_request"
    t.integer "selector_working_hours_request"
    t.integer "selector_monthly_request"
    t.date "date_monthly_request"
    t.boolean "change_overtime"
    t.boolean "change_working_hours"
    t.boolean "change_monthly"
    t.string "status_overtime"
    t.string "status_working_hours"
    t.string "status_monthly"
    t.datetime "year_starting"
    t.datetime "year_ending"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "branch_offices", force: :cascade do |t|
    t.string "branch_office_name"
    t.string "branch_office_number"
    t.string "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2023-08-29 23:00:00"
    t.datetime "work_time", default: "2023-08-29 22:30:00"
    t.string "affiliation"
    t.integer "employee_number"
    t.string "uid"
    t.boolean "superior", default: false
    t.datetime "designated_work_start_time", default: "2023-08-30 00:00:00"
    t.datetime "designated_work_end_time", default: "2023-08-30 09:00:00"
    t.datetime "basic_work_time", default: "2023-08-29 23:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
