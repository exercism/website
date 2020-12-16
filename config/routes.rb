require 'sidekiq/web'

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # #### #
  # Auth #
  # #### #
  devise_for :users, controllers: {
    sessions: "auth/sessions",
    registrations: "auth/registrations",
    omniauth_callbacks: "auth/omniauth_callbacks",
    confirmations: "auth/confirmations",
    passwords: "auth/passwords"
  }

  devise_scope :user do
    get "confirmations/required" => "auth/confirmations#required", as: "auth_confirmation_required"
  end

  # ### #
  # API #
  # ### #
  namespace :api do
    scope :v1 do
      get "ping" => "ping#index"
      get "validate_token" => "validate_token#index"

      resources :tracks, only: %i[index show]
      resources :bug_reports, only: %i[create]
      resources :solutions, only: %i[show update] do
        get :latest, on: :collection

        get 'files/*filepath', to: 'files#show', format: false, as: "file"
        resources :submissions, only: %i[create]
        resources :iterations, only: %i[create]
      end
      resources :solution, only: [] do
        resources :initial_files, only: %i[index], controller: "solutions/initial_files"
      end

      resources :mentor_requests, only: %i[index] do
        member do
          patch :lock
        end
      end

      resources :mentor_discussions, only: %i[index create] do
        get :tracks, on: :collection # TODO: Remove this
        resources :posts, only: %i[create], controller: "mentor_discussion_posts"
      end

      resources :submission, only: [] do
        resource :test_run, only: %i[show], controller: "submissions/test_runs"
        resources :cancellations, only: %i[create], controller: "submissions/cancellations"
      end

      resources :profiles, only: [] do
        get :summary, on: :member
      end
    end
  end
  get "api/(*url)", to: 'api/errors#render_404'

  # ### #
  # SPI #
  # ### #
  namespace :spi do
    resources :tooling_jobs, only: :update
  end

  # ######## #
  # Webhooks #
  # ######## #
  namespace :webhooks do
    resource :repo_updates, only: [:create]
  end

  # ############ #
  # Normal pages #
  # ############ #

  resources :profiles, only: [:show] do
    member do
      get :tooltip
    end
  end

  namespace :mentor do
    get "/", to: redirect("mentor/dashboard")
    resource :dashboard, only: [:show], controller: "dashboard"
    resources :requests, only: [:show] do
      get :unavailable, on: :member
    end
    resources :discussions, only: [:show]
  end

  namespace :maintaining do
    resources :submissions, only: [:index]
    resources :exercise_representations
  end
  resources :tracks, only: %i[index show] do
    resources :concepts, only: %i[index show], controller: "tracks/concepts" do
      get :tooltip, on: :member
    end

    resources :exercises, only: %i[index show edit], controller: "tracks/exercises" do
      member do
        patch :start
        patch :complete
      end

      resources :iterations, only: [:index], controller: "tracks/iterations"

      resources :mentoring, only: [:index], controller: "tracks/mentoring"
      resource :mentoring_request, only: [:create], controller: "tracks/mentoring_requests"
    end

    member do
      post :join
    end
  end

  resource :user_onboarding, only: %i[show create], controller: "user_onboarding"

  root to: "pages#index"

  ##############
  # ELB routes #
  ##############
  get "health-check", to: 'pages#health_check'

  #################
  # Legacy routes #
  #################
  get "solutions/:uuid" => "legacy#solution"
  get "my/solutions/:uuid" => "legacy#solution"
  get "mentor/solutions/:uuid" => "legacy#solution"

  # ########################### #
  # Temporary and testing pages #
  # ########################### #

  namespace :tmp do
    resources :submissions, only: [:create]
    resources :tracks, only: [:create]
    post "git/pull" => "git#pull", as: "pull_git"
  end

  unless Rails.env.production?
    namespace :test do
      namespace :components do
        resource :editor, only: [:show], controller: "editor"

        namespace :student do
          resource :concept_map, only: [:show], controller: 'concept_map'
          resource :tracks_list, only: [:show], controller: "tracks_list" do
            member do
              get 'tracks'
            end
          end
        end
        namespace :maintaining do
          get 'submissions_summary_table', to: 'submissions_summary_table#index', as: 'submissions_summary_table'
        end
        resource :notifications_icon, only: %i[show update]
        namespace :mentoring do
          resource :queue, controller: "queue", only: [:show] do
            get 'solutions', on: :member
          end
          resource :inbox, controller: "inbox", only: [:show] do
            member do
              get 'tracks'
              get 'conversations'
            end
          end
        end
        namespace :tooltips do
          resource :tooltip, controller: "tooltip", only: [:show] do
            get 'mentored_student/:id', to: 'tooltip#mentored_student', as: 'mentored_student'
            get 'user_summary/:id', to: 'tooltip#user_summary', as: 'user_summary'
          end
        end
        namespace :common do
          resource :copy_to_clipboard_button, controller: "copy_to_clipboard_button", only: [:show]
          resource :icons, controller: "icons", only: [:show]
        end
      end
      namespace :templates do
        resource :concept_tooltip, only: "show"
      end
    end
  end
end
