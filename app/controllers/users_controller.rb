class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_or_correct_user, only: :show
  before_action :set_one_month, only: :show


  def index
    @users = User.paginate(page: params[:page]).search(params[:search]).order(id: "ASC")
    @search_user = params[:search]
  end


  def import
    # CSVファイルが選択されていない場合、エラーメッセージを表示
    if params[:csv_file].blank?
      flash[:danger] = '読み込むCSVを選択してください'
    # 選択されたファイルがCSVファイルでない場合、エラーメッセージを表示してリダイレクト
    elsif File.extname(params[:csv_file].original_filename) != '.csv'
      flash[:danger] = 'csvファイル以外は出力できません'
      redirect_to users_url and return
    # 正常な場合、CSVファイルを読み込んでデータベースに追加し、成功メッセージを表示
    else
      User.import(params[:csv_file])
      flash[:success] = 'CSVファイルの情報を追加しました'
    end
    # どの場合でもユーザー一覧画面にリダイレクトする
    redirect_to users_path and return
  end


  def show
    @worked_sum = @attendances.where.not(started_at: nil).count

    @attendance = @user.attendances.find_by(worked_on: @first_day)

    # 上長　申請中をカウントして赤字で表示する
    # 上長　自身宛ての申請があり、かつステータスが申請中のときに、その数をカウントする
    if @user.superior?
      @count_monthly_request = Attendance.where(selector_monthly_request: @user.employee_number,
                                                status_monthly: '申請中').count
      @count_working_hours_request = Attendance.where(selector_working_hours_request: @user.employee_number,
                                                      status_working_hours: '申請中').count
      @count_overtime_request = Attendance.where(selector_overtime_request: @user.employee_number,
                                                status_overtime: '申請中').count
    end
  # 月初日を取得。
    # 申請者が1ヶ月申請を押したときに月初日に「申請中」が入る
    # 上長が「なし」「申請中」「否認」「承認」のどれかを選択することでstatusが変更される
    @first_day_monthly_request = @user.attendances.find_by(worked_on: @first_day)

    # status_monthlyの値に基づいて、ステータスを更新
    case @first_day_monthly_request.status_monthly
    when '申請中'
      # selector_monthly_requestの値に応じてステータスを更新
      if @first_day_monthly_request.selector_monthly_request == 201
        @status_updated = '所属長 上長1に申請中'
      else
        @first_day_monthly_request.selector_monthly_request == 202
        @status_updated = '所属長 上長2に申請中'
      end
    when '承認'
      # selector_monthly_requestの値に応じてステータスを更新
      if @first_day_monthly_request.selector_monthly_request == 201
        @status_updated = '所属長 上長1に承認されました'
      else
        @first_day_monthly_request.selector_monthly_request == 202
        @status_updated = '所属長 上長2に承認されました'
      end
    when '否認'
      # selector_monthly_requestの値に応じてステータスを更新
      if @first_day_monthly_request.selector_monthly_request == 201
        @status_updated = '所属長 上長1に否認されました'
      else
        @first_day_monthly_request.selector_monthly_request == 202
        @status_updated = '所属長 上長2に否認されました'
      end
    else
      @status_updated = '所属長 承認 未送信'
    end

# respond_to ブロック開始
    respond_to do |format|
      # format.html の処理を記述
      format.html do
      end
      # CSV フォーマットの処理を記述
      format.csv do
        send_data render_to_string, filename: "#{@user.name}さんの勤怠一覧.csv", type: :csv
      end
    end
  end


  def new
    @user = User.new
  end


  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end


  def edit
  end


  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end


  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end


  def edit_basic_info
  end


  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  # 残業申請への返答 表示
  def edit_overtime_approval
    @user = User.find(params[:user_id]) # @userは自身(上長1または上長2)
    # @users = User.joins(:attendances).group("users.id").where(attendances: { selector_overtime_request: @user.employee_number, status_overtime: "申請中" } )
    @attendances = Attendance.where(selector_overtime_request: @user.employee_number,
                                    status_overtime: '申請中').order(user_id: 'ASC').group_by(&:user_id)
  end

# 残業申請への返答 更新
  def update_overtime_approval
    @user = User.find(params[:user_id])

    ActiveRecord::Base.transaction do
      overtime_approval_params.each do |id, item|
        # 「変更」をチェックしたら以下を実行　「変更」にチェックが無い場合は何もしないまま終了
        next unless item[:change_overtime] == 'true'

        attendance = Attendance.find(id)
        # 以下で、form_withには入っていない属性をitemに入れると、ストロングパラメーターで許可された属性のみupdate_attributes!(item)でデータベースに保存される
        # itemに入っていない属性はupdate_attributes!(item)ではデータベースには保存されない
        if item[:status_overtime] == '承認'
          if attendance.estimated_overtime_hours.present?
            item[:estimated_overtime_hours] =
              attendance.estimated_overtime_hours
          end
          item[:next_day_overtime] = attendance.next_day_overtime if attendance.next_day_overtime.present?
          if attendance.business_process_content.present?
            item[:business_process_content] =
              attendance.business_process_content
          end
        end
        # 「なし」を選択すると、parameterの値が全部削除される
        if item[:status_overtime] == 'なし'
          item[:status_overtime] = nil
          attendance.estimated_overtime_hours = nil
          attendance.next_day_overtime = nil
          attendance.estimated_overtime_hours = nil
        end
        attendance.update_attributes!(item)
        # if
      end
    end

      flash[:success] = '残業申請の内容について更新しました。'
      redirect_to @user and return
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = '無効な入力データがあった為、更新をキャンセルしました。'
      redirect_to user_edit_overtime_approval_path(@user) and return
  end

  def edit_working_hours_approval
    @user = User.find(params[:user_id])
    # joinsでuserとattendancesを結合させて表示できる。whereでattendancesを絞り込む。
    @users = User.joins(:attendances).group('users.id').where(attendances: {
                                                                selector_working_hours_request: @user.employee_number, status_working_hours: '申請中'
                                                              })
    @attendances = Attendance.where(selector_working_hours_request: @user.employee_number,
                                    status_working_hours: '申請中').order(worked_on: 'ASC')
    @attendances.each do |attendance|
      attendance.change_working_hours = nil
    end
  end

  def update_working_hours_approval
    # パラメーターの情報を更新する
    ActiveRecord::Base.transaction do
    # itemにはform_withで入力されたparamsの値が入っている
    working_hours_approval_params.each do |id, item|
      # 以下で、form_withには入っていない属性をitemに入れると、ストロングパラメーターで許可された属性のみupdate_attributes!(item)でデータベースに保存される
      # itemに入っていない属性はupdate_attributes!(item)ではデータベースには保存されない
      next unless item[:change_working_hours] == 'true'

      # attendanceにはidから見つけたattendanceのデータベースの値が入る
      attendance = Attendance.find(id)
      if item[:status_working_hours] == '承認'
        # 以下の値をitemに新たに追加する
        item[:started_at_before] = attendance.started_at if attendance.started_at_before.blank?
        item[:finished_at_before] = attendance.finished_at if attendance.finished_at_before.blank?
        item[:started_at] = attendance.started_at_edited
        item[:finished_at] = attendance.finished_at_edited
      end
      # 「なし」を選択すると、parameterの値が全部削除される
      if item[:status_working_hours] == 'なし'
        # パラメーターに残っている以下の値を削除する
        item[:status_working_hours] = nil
        attendance.started_at_edited = nil
        attendance.finished_at_edited = nil
        attendance.note = nil
        attendance.selector_working_hours_request = nil
      end
      attendance.update_attributes!(item)
    end
  end

  flash[:success] = '勤怠情報の変更について更新しました。'
    redirect_to user_url(params[:user_id]) and return
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = '無効なデータがあったため、更新をキャンセルしました'
    redirect_to user_url(params[:user_id]) and return
  end


  def attendance_confirmation
    @worked_sum = @attendances.where.not(started_at: nil).count
  end


  def attendance_log
    @user = User.find(params[:id])
    if params['worked_on(1i)'].present? && params['worked_on(2i)'].present? # worked_on(1i)は年　worked_on(2i)は月
      selected_year_and_month = "#{params['worked_on(1i)']}/#{params['worked_on(2i)']}" # "2021/05"
      # @day = Sat, 01 May 2021 00:00:00 +0000
      @day = DateTime.parse(selected_year_and_month) if selected_year_and_month.present?
      @attendances = @user.attendances.where(status_working_hours: '承認').where(worked_on: @day.all_month) # 承認済みをwhereで絞り込む
    else
      @attendances = @user.attendances.where(status_working_hours: '承認').order('worked_on ASC') # 全ての承認済みを日付順で出す
    end
  end


  def working_employees
    @users = User.all.includes(:attendances)
  end


  private


  def overtime_approval_params
    params.require(:user).permit(attendances: %i[status_overtime change_overtime estimated_overtime_hours
                                                next_day_overtime business_process_content])[:attendances]
  end

  def working_hours_approval_params
    params.require(:user).permit(attendances: %i[started_at_before finished_at_before started_at finished_at
                                                started_at_edited finished_at_edited status_working_hours change_working_hours])[:attendances]
  end

  def user_params
    params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
  end


  def basic_info_params
    params.require(:user).permit(:department, :basic_time, :work_time)
  end

end