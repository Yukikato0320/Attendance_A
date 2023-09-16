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
    t.date "worked_on"  # 勤務日
    t.datetime "started_at"  # 出社時間
    t.datetime "finished_at"  # 退社時間
    t.string "note"  # 備考
    t.integer "user_id"  # ユーザーID
    t.datetime "created_at", null: false  # 作成日時
    t.datetime "updated_at", null: false  # 更新日時
    t.datetime "started_at_before"  # 出社時間(変更前)
    t.datetime "finished_at_before"  # 退社時間(変更前)
    t.datetime "started_at_edited"  # 出社時間(変更後)
    t.datetime "finished_at_edited"  # 退社時間(変更後)
    t.datetime "estimated_overtime_hours"  # 残業申請(終了予定時間)-予想残業時間
    t.string "business_process_content"  # 残業申請(業務処理内容)
    t.boolean "next_day_overtime"  # 残業申請(翌日)
    t.boolean "next_day_working_hours"  # 勤怠編集画面(翌日)
    t.integer "selector_overtime_request"  # 指示者確認(残業申請) ※ 上長1または上長2が入る
    t.integer "selector_working_hours_request"  # 指示者確認(勤怠変更申請) ※ 上長1または上長2が入る
    t.integer "selector_monthly_request"  # 指示者確認(1ヶ月勤怠変更申請) ※ 上長1または上長2が入る
    t.date "date_monthly_request"  # 1ヶ月勤怠変更申請日時
    t.boolean "change_overtime"  # 残業変更
    t.boolean "change_working_hours"  # 勤怠変更
    t.boolean "change_monthly"  # 1ヶ月勤怠変更
    t.string "status_overtime"  # 残業のステータス
    t.string "status_working_hours"  # 勤怠変更のステータス
    t.string "status_monthly"  # 1ヶ月勤怠変更のステータス
    t.datetime "year_starting"  # 最初の年(開始年)
    t.datetime "year_ending"  # 最後の年(終了年)
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "branch_offices", force: :cascade do |t|
    t.string "branch_office_name"  # 拠点名
    t.string "branch_office_number"  # 拠点番号
    t.string "attendance_type"  # 勤怠種類
    t.datetime "created_at", null: false  # 作成日時
    t.datetime "updated_at", null: false  # 更新日時
  end

  create_table "users", force: :cascade do |t|
    t.string "name"  # 名前
    t.string "email"  # メールアドレス
    t.datetime "created_at", null: false  # 作成日時
    t.datetime "updated_at", null: false  # 更新日時
    t.string "password_digest"  # パスワードダイジェスト
    t.string "remember_digest"  # リメンバーダイジェスト
    t.boolean "admin", default: false  # 管理者フラグ
    t.string "department"  # 部署(勤怠Bからの使用カラム)
    t.datetime "basic_time", default: "2023-08-29 23:00:00"  # 基本勤務時間((勤怠Bからの使用カラム)
    t.datetime "work_time", default: "2023-08-29 22:30:00"  # 勤怠時間(勤怠Bからの使用カラム)
    t.string "affiliation"  # 所属
    t.integer "employee_number"  # 社員番号
    t.string "uid"  # ユーザーID
    t.boolean "superior", default: false #  上長
    t.datetime "designated_work_start_time", default: "2023-08-30 00:00:00"  # 指定勤務開始時間
    t.datetime "designated_work_end_time", default: "2023-08-30 09:00:00"  # 指定勤務終了時間
    t.datetime "basic_work_time", default: "2023-08-29 23:00:00"  # 基本勤務時間
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
