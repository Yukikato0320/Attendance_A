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


    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end


    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end
end