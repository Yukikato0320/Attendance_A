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
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'

      get 'attendance_confirmation'
      # GET /users/:id/attendance_log
      get 'attendance_log' # 勤怠ログ(承認済み)

    end

    collection do
      get 'working_employees'
    end

    

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