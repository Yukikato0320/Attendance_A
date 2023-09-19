class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :update_monthly_request]
  before_action :logged_in_user, only: [:update, :edit_one_month]
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

    flash[:success] = "1ヶ月分の勤怠情報を更新しました。" #トランザクションが正常に稼働したら、出現。
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。" #トランザクションが失敗したら、出現。
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end


  # 残業申請 表示/編集
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


  # 画面右下の1ヶ月申請ボタンを押したときのアクション(1ヶ月勤怠変更)
  def update_monthly_request
    # @userはset_userでセットしている
    @attendance = @user.attendances.where(worked_on: params[:attendance][:date_monthly_request])

    # 上長を選択したら申請が可能 (selector_monthly_request = 1ヶ月の勤怠変更の指示者確認[routes])
    if monthly_request_params[:selector_monthly_request].present?
      @attendance.update(monthly_request_params)
      flash[:success] = "#{@user.name}の1ヶ月分の勤怠情報を申請しました。"
    else
      flash[:danger] = '上長を選択して下さい。'
    end
    redirect_to @user
  end


  def edit_monthly_approval
    # 上長をパラメーターから取得する
    # パラメーターから指定されたユーザーIDに対応するユーザーオブジェクトを取得し、@userに代入
    @user = User.find(params[:id]) # 上長
    # 上長への申請中の、1ヶ月勤怠変更承認リクエストを取得する
    @users = User.joins(:attendances).group('users.id').where(attendances: {
                                                                selector_monthly_request: @user.employee_number, status_monthly: '申請中'
                                                              })
    # 上長のIDと同じ番号のattendance.selector_monthly_requestを持つ勤怠レコードを取得し、申請中の1ヶ月勤怠変更承認ステータスで昇順に並べ替える
    @attendances = Attendance.where(selector_monthly_request: @user.employee_number,
                                    status_monthly: '申請中').order(worked_on: 'ASC')
    # 取得した勤怠レコードの各レコードに対して、change_monthlyフィールドをnullに設定する
    @attendances.each do |attendance|
      attendance.change_monthly = nil
    end
  end


  def update_monthly_approval
    #トランジャクションを開始。トランザクション内の操作はすべて成功するか失敗するかのいずれかで、一括して処理。
    ActiveRecord::Base.transaction do
      # パラメータから送信された1ヶ月勤怠変更承認情報を処理
      monthly_approval_params.each do |id, item|
        # "change_monthly" フィールドが "true" でない場合は処理をスキップ。
        next unless item[:change_monthly] == 'true'

        # 勤怠レコードを特定し、送信された情報で更新
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
      flash[:success] = '1ヶ月分の勤怠情報を更新しました。'
      redirect_to user_url(params[:id]) and return
    end
  # トランザクション内での操作に失敗した場合、無効なデータがあったことを示すエラーメッセージを設定し、ユーザーの詳細ページにリダイレクト。
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = '無効なデータがあったため、更新をキャンセルしました'
    redirect_to user_url(params[:id]) and return
  end


  private


  # ユーザー1名で単数の勤怠を更新する場合はこの書き方で
  def overtime_request_params
    params.require(:attendance).permit(:estimated_overtime_hours, :next_day_overtime, :business_process_content,
                                      :selector_overtime_request, :status_overtime)
  end


  def monthly_request_params
    params.require(:attendance).permit(:date_monthly_request, :status_monthly, :selector_monthly_request)
  end


  def monthly_approval_params
    params.require(:user).permit(attendances: [:status_monthly, :change_monthly])[:attendances]
  end


  # 1ヶ月分の勤怠情報を扱います。(勤怠Bよりそのまま引き継ぎ部)
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
  end


# beforeフィルター


  # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    return if current_user?(@user) || current_user.admin?

    flash[:danger] = '編集権限がありません。'
    redirect_to(root_url)
  end

end