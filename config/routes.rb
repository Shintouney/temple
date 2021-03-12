require "sidekiq/web"

Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
Sidekiq::Web.set :sessions, Rails.application.config.session_options

if Rails.env.production? || Rails.env.staging?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Settings.sidekiq.username)) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Settings.sidekiq.password))
  end
end

Temple::Application.routes.draw do
  mount Sidekiq::Web => "/nemo"

  get "invoices/index"
  root 'home#index'

  delete "logout" => "sessions#destroy"
  get "login" => "sessions#new"
  resources :sessions, only: [:index, :create]

  resource :password, only: [:new, :create, :edit, :update]

  resources :card_scans, only: [:create]

  post 'destroy_pending_mandates/:user_id' => 'slimpay#destroy_pending_mandates', as: :destroy_pending
  post 'ipn' => 'slimpay#ipn'
  post 'sepa/:user_id' => 'slimpay#sepa', as: :sepa
  get 'mandate_signature_return' => 'slimpay#mandate_signature_return'
  delete 'mandates/:id/destroy' => 'slimpay#destroy', as: :destroy_mandate

  namespace :admin do
    root to: 'visits#index', via: :get

    resources :users, only: [:show, :edit, :update, :new, :create] do

      member do
        post :force_access_to_planning
        post :forbid_access_to_planning
        patch :change_payment_mode
      end

      collection do
        get :active
        get :inactive
        get :red_list
        get :temporarily_suspended_users
        get :update_origin_location
      end

      resources :orders, only: [:new, :create, :show, :destroy, :index]
      resources :invoices, only: [:index, :show, :update] do
        member do
          get :payments
          get :credit_note
        end
      end

      resource :card, only: [:edit, :update, :destroy] do
        get :print, on: :member
        post :force_authorization, on: :member
      end
      resource :credit_card, only: [:show, :edit, :update]
      resource :subscription, only: [:edit, :update, :destroy] do
        post :restart
      end
      resource :suspended_subscription_schedule, only: [:create, :destroy]

      resources :user_images, only: [:create, :destroy, :index] do
        put :make_profile_image, on: :member
      end
    end

    resources :announces, except: :show

    resources :article_categories, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :articles, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :groups, only: [:index, :new, :create, :edit, :update, :destroy] do
      get :export, on: :member
    end

    resources :lesson_drafts, only: [:index, :show, :create, :new, :edit, :update, :destroy]
    resources :lesson_templates, only: [:index, :show, :create, :new, :edit, :update, :destroy]
    resources :lessons, only: [:index, :show, :new, :create, :edit, :update, :destroy]

    resources :subscription_plans, only: [:index, :new, :create, :edit, :update, :destroy] do
      post :update_positions, on: :collection
      delete :disable, on: :member
    end

    resources :visits, only: [:index, :create, :show] do
      get :search_user_by_name, on: :collection
      get :logs, on: :collection
      post :finish, on: :member
    end

    resources :card_scans, only: [:index] do
      get :shortlog, on: :collection
    end

    resources :staff_users, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :admin_users, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :exports, only: [:index, :create, :show] do
      collection do
        get :order_items
        get :visits
        get :subscriptions
        get :red_list
        get :refresh_link
      end
      get :progress, on: :member
    end

    resources :lesson_requests, only: [:index]
    resources :unsubscribe_requests, only: [:index]
    resources :sponsoring_requests, only: [:index]
  end

  namespace :account do
    root to: 'dashboard#index', via: :get

    resources :invoices, only: [:index, :show] do
      member do
        get :credit_note
      end
    end

    resources :lessons, only: [:index] do
      resource :lesson_booking, only: [:create, :destroy]
    end

    resource :user, only: [:show, :update]
    resource :profile, only: [:edit, :update]

    get "contact/show", as: :contact

    resources :invitations, only: [:new, :create]
    resources :notifications, only: [:create, :destroy]

    resources :payment_means, only: [:index]

    resource :lesson_request, only: [:new, :create]

    resource :sponsoring_request, only: [:new, :create]

    get "pages/*id" => 'pages#show', as: :page, format: false
  end

  resources :subscription_plans, only: [:index, :show] do
    get :embed, on: :collection
    post :buy, on: :member
  end

  namespace :subscription do
    resource :payment, only: [:new, :create, :show]
  end

  resources :lessons, only: [:index, :show]

  resource :unsubscribe_request, only: [:new, :create ,:show]

  unless Rails.application.config.consider_all_requests_local
    match "/404", to: "errors#not_found", via: :all
    match "/422", to: "errors#unprocessable_entity", via: :all
    match "/500", to: "errors#internal_server_error", via: :all
    match "/maintenance", to: "errors#maintenance", via: :all
  end
end
