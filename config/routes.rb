Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :branch_offices

  resources :users do
    # collectionは:id無し
    # CSVインポート POST /users/import
    collection { post :import }
    # memberは:idあり
    member do
      # GET	/users/:id/edit_basic_info 基本情報の編集ページ
      get 'edit_basic_info'
      # PATCH	/users/:id/update_basic_info 基本情報の更新
      patch 'update_basic_info'

      # GET /users/:id/attendances/edit_one_month ユーザーに紐付いた勤怠情報の集合(1ヶ月分)を編集
      get 'attendances/edit_one_month'
      # PATCH /users/:id/attendances/update_one_month ユーザーに紐付いた勤怠情報の集合(1ヶ月分)を更新
      patch 'attendances/update_one_month'

      # PATCH /users/:id/attendances/update_monthly_request
      patch 'attendances/update_monthly_request' # 1ヶ月申請の更新 上長を選択して申請

      # GET /users/:id/edit_monthly_approval 上長 1ヶ月モーダル 表示
      get 'attendances/edit_monthly_approval'
      # GET /users/:id/update_monthly_approval 上長 1ヶ月モーダル 更新
      patch 'attendances/update_monthly_approval'
      # GET /users/:id/attendance_confirmation 承認/確認ページ
      get 'attendance_confirmation'
      # GET /users/:id/attendance_log  # 勤怠修正ログ(承認済み)ページ
      get 'attendance_log'

      # 基本情報の修正ページ
      get 'edit_basic_info2'
    end

    # 出勤社員一覧ページ
    collection do
      get 'working_employees'
    end

    # 上長1 & 上長2 モーダル各種
    # GET /users/:user_id/edit_overtime_approval
    get 'edit_overtime_approval' # 上長 残業モーダル 編集
    # PATCH /users/:user_id/update_overtime_approval
    patch 'update_overtime_approval' # 上長 残業モーダル 更新

    # GET /users/:user_id/edit_working_hours_approval
    get 'edit_working_hours_approval' # 上長 勤怠変更モーダル 編集
    # PATCH /users/:user_id/update_working_hours_approval
    patch 'update_working_hours_approval' # 上長勤怠変更モーダル 更新


    resources :attendances, only: :update do
      member do
        # GET /users/:user_id/attendances/:id/edit_overtime_request
        get 'edit_overtime_request' # 残業申請モーダル
        # PATCH /users/:user_id/attendances/:id/update_overtime_request
        patch 'update_overtime_request' # 残業申請モーダル 更新
      end
    end
  end
end