class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # SessionsHelperはどこでも使える
  include SessionsHelper

  $days_of_the_week = %w{日 月 火 水 木 金 土}


  # beforフィルター


  # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
  end


  # ログイン済みのユーザーか確認します。
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end


  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end


  # システム管理権限所有かどうか判定します。
  def admin_user
    redirect_to root_url unless current_user.admin?
  end


  def non_admin_user
    redirect_to root_url if current_user.admin?
  end


  # 下記勤怠Bからの継承。 勤怠Aでは、上記 non_admin_user としてバリデーションにて置き換え利用。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "権限がありません"
      redirect_to current_user
    end
  end


  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end

  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end


  private


  def user_params
    params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation, :uid,
                                :employee_number, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
  end


  # ユーザー1名で複数の勤怠を更新する場合はこの書き方で。
  def attendances_params
    params.require(:user).permit(attendances: %i[started_at finished_at started_at_edited finished_at_edited
                                                started_at_before finished_at_before note next_day_working_hours selector_working_hours_request status_working_hours selector_monthly_request])[:attendances]
  end


end