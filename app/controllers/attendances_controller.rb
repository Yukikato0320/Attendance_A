class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
  end

  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item) #ここでオブジェクトのカラム全体を更新(この時点ではレコードに保存していない)
        attendance.save!(context: :update_one_month) #ここで↑で更新した値をレコードに保存(同時にバリデーションを実行)
      end
    end

    flash[:success] = "1ヶ月分の勤怠情報を更新しました。" #トランザクションが正常に稼働したら出る。
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。" #トランザクションが失敗したら出る。
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end


  # 残業申請 表示
  def edit_overtime_request
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
  end

  # 残業申請 提出
  def update_overtime_request
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])

    if overtime_request_params[:next_day_overtime] == 'false' && (overtime_request_params[:estimated_overtime_hours].to_i < @user.designated_work_end_time.hour)
      flash[:danger] = '無効な入力データがあった為、更新をキャンセルしました。'
      redirect_to @user and return
    end

    if overtime_request_params[:next_day_overtime] == 'true' && (overtime_request_params[:estimated_overtime_hours].to_i > @user.designated_work_end_time.hour)
      flash[:danger] = '無効な入力データがあった為、更新をキャンセルしました。'
      redirect_to @user and return
    end

    if overtime_request_params[:estimated_overtime_hours].present? && overtime_request_params[:selector_overtime_request].blank?
      flash[:danger] = '無効な入力データがあった為、更新をキャンセルしました。'
      redirect_to @user and return
    end

    flash[:success] = "#{@user.name}の残業申請が完了しました。" if @attendance.update_attributes  (overtime_request_params)
    redirect_to @user and return
  end




  private

  # 1ヶ月分の勤怠情報を扱います。
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
  end

end