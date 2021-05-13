require 'sidekiq/web'
require 'sidekiq/cron/web'

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
    namespace :v1 do # rubocop:disable Naming/VariableNumber
      get "ping" => "ping#index"
      get "validate_token" => "validate_token#index"

      resources :solutions, only: %i[show update] do
        get :latest, on: :collection
        get 'files/*filepath', to: 'files#show', format: false, as: "file"
      end

      resources :tracks, only: [:show]
    end

    scope :v2 do # rubocop:disable Naming/VariableNumber
      get "ping" => "ping#index"
      get "validate_token" => "validate_token#index"

      namespace :settings do
        resources :introducers, only: [] do
          patch :hide, on: :member
        end
      end

      resources :tracks, only: %i[index show] do
        resources :exercises, only: %i[index], controller: "exercises" do
          resources :community_solutions, only: [:index], controller: "community_solutions" do
            resource :star, only: %i[create destroy], controller: "community_solution_stars"
          end
        end
      end

      get "/scratchpad/:category/:title" => "scratchpad_pages#show", as: :scratchpad_page
      patch "/scratchpad/:category/:title" => "scratchpad_pages#update"

      resources :bug_reports, only: %i[create]

      resources :notifications, only: [:index]

      resources :reputation, only: %i[index] do
        member do
          patch :mark_as_seen
        end
      end

      resources :badges, only: %i[index]

      resources :profiles, only: [] do
        get :summary, on: :member

        resources :testimonials, only: [:index], controller: "profiles/testimonials"
        resources :solutions, only: [:index], controller: 'profiles/solutions'
        resources :contributions, only: [], controller: 'profiles/contributions' do
          collection do
            get :building
            get :maintaining
            get :authoring
          end
        end
      end

      resources :solutions, only: %i[index show update] do
        member do
          patch :complete
          patch :publish
          patch :unpublish
          patch :published_iteration
        end

        resources :submissions, only: %i[create], controller: "solutions/submissions" do
          resource :test_run, only: %i[show], controller: "solutions/submission_test_runs"
          resources :cancellations, only: %i[create], controller: "solutions/submission_cancellations"
          resources :files, only: %i[index], controller: "solutions/submission_files"
        end

        resources :iterations, only: %i[create] do
          get :latest_status, on: :collection
        end
        resources :initial_files, only: %i[index], controller: "solutions/initial_files"

        resource :mentor_request, only: %i[create], controller: "solutions/mentor_requests"
        resources :discussions, only: %i[index create], controller: "solutions/mentor_discussions" do
          patch :finish, on: :member
          resources :posts, only: %i[index create update], controller: "solutions/mentor_discussion_posts"
        end
      end

      namespace :mentoring do
        resource :registration, only: %i[create], controller: 'registration'
        resource :tracks, only: %i[show update] do
          get :mentored
        end

        resources :requests, only: %i[index] do
          collection do
            get :tracks
            get :exercises
          end
          member do
            patch :lock
          end
        end

        resources :discussions, only: %i[index create] do
          member do
            patch :mark_as_nothing_to_do
            patch :finish
          end

          collection do
            get :tracks # TODO: Remove this
          end

          resources :posts, only: %i[index create update], controller: "discussion_posts"
        end

        resources :testimonials, only: [:index] do
          member do
            patch :reveal
          end
        end

        resources :students, only: [] do
          member do
            post :block
            delete :block, to: "students#unblock"
            post :favorite
            delete :favorite, to: "students#unfavorite"
          end
        end
      end

      post "markdown/parse" => "markdown#parse", as: "parse_markdown"
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
    resource :push_updates, only: [:create]
    resource :pull_request_updates, only: [:create]
    resource :organization_updates, only: [:create]
  end

  # ############ #
  # Normal pages #
  # ############ #
  resource :dashboard, only: [:show], controller: "dashboard"

  resources :docs, only: %i[index]
  get 'docs/tracks/:track_slug/*slug', to: 'docs#track_show', as: :track_doc
  get 'docs/tracks/:track_slug', to: 'docs#track_index', as: :track_docs
  get 'docs/tracks', to: 'docs#tracks'
  get 'docs/:section/*slug', to: 'docs#show', as: :doc
  get 'docs/:section', to: 'docs#section', as: :docs_section

  resources :notifications, only: [:index]

  resources :profiles, only: %i[show new create] do
    collection do
      get :intro
    end

    member do
      get :tooltip

      get :solutions
      get :badges
      get :testimonials
      get :contributions
    end
  end

  namespace :mentoring do
    get "/", to: "external#show"
    resource :inbox, only: [:show], controller: "inbox"
    resource :queue, only: [:show], controller: "queue"
    resources :requests, only: [:show] do
      get :unavailable, on: :member
    end
    resources :discussions, only: [:show]
    resources :testimonials, only: [:index]
  end

  namespace :maintaining do
    root to: "dashboard#show"
    resources :submissions, only: [:index]
    resources :exercise_representations
    resources :tracks, only: [:show]
  end

  resources :tracks, only: %i[index show] do
    resources :concepts, only: %i[index show], controller: "tracks/concepts" do
      get :tooltip, on: :member
    end

    resources :exercises, only: %i[index show edit], controller: "tracks/exercises" do
      member do
        get :tooltip
        patch :start
        patch :complete # TODO: Remove once via the API.
      end

      resources :iterations, only: [:index], controller: "tracks/iterations"

      resources :mentor_discussions, only: [:index], controller: "tracks/mentor_requests"
      resource :mentor_request, only: %i[new show], controller: "tracks/mentor_requests"
      resources :mentor_discussions, only: [:show], controller: "tracks/mentor_discussions"

      resources :community_solutions, only: %i[index show], controller: "tracks/community_solutions"
      resources :solutions, only: %i[show], controller: "tracks/community_solutions"
    end

    member do
      post :join
    end
  end

  resource :user_onboarding, only: %i[show create], controller: "user_onboarding"
  resource :journey, only: [:show], controller: "journey" do
    member do
      get :solutions
      get :reputation
      get :badges
    end
  end

  get "code-of-conduct" => "docs/code_of_conduct", as: :code_of_conduct
  get "terms-of-services" => "docs/terms_of_services", as: :terms_of_service
  get "privacy-policy" => "docs/privacy_policy", as: :privacy_policy
  get "licences/cc-sa-4" => "licences/cc_sa_4_licence", as: :cc_sa_4_licence
  get "licences/mit" => "licences/mit", as: :mit_licence

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

  # TODO: Remove these before launching
  namespace :temp do
    resources :tracks, only: [:create]
    resources :modals, only: [] do
      collection do
        get :mentoring_sessions
        get :publish_exercise
        get :completed_exercise
        get :welcome_to_v3 # rubocop:disable Naming/VariableNumber
        get :reputation
        get :mentoring_dropdown
        get :exercise_tooltip
        get :select_exercise_for_mentoring
      end
    end
    resource :mentoring, only: [], controller: "mentoring" do
      get :student_request
    end
    resource :mentored_tracks, only: %i[show update]
    resources :tracks, only: [] do
      resources :exercises, only: [], controller: "tracks/exercises" do
        member do
          patch :start
        end
      end
    end
  end

  unless Rails.env.production?
    namespace :test do
      namespace :components do
        resource :editor, only: [:show], controller: "editor"
        namespace :student do
          resource :concept_map, only: [:show], controller: 'concept_map'
        end
        namespace :maintaining do
          get 'submissions_summary_table', to: 'submissions_summary_table#index', as: 'submissions_summary_table'
        end

        namespace :mentoring do
          resource :discussion, controller: "discussion", only: [:show]
        end
        namespace :tooltips do
          resource :tooltip, controller: "tooltip", only: [:show] do
            get 'mentored_student/:id', to: 'tooltip#mentored_student', as: 'mentored_student'
            get 'user_summary/:id', to: 'tooltip#user_summary', as: 'user_summary'
          end
        end
        namespace :common do
          resource :expander, controller: "expander", only: [:show]
          resource :copy_to_clipboard_button, controller: "copy_to_clipboard_button", only: [:show]
          resource :markdown_editor, controller: "markdown_editor", only: [:show]
          resource :icons, controller: "icons", only: [:show]
          resource :introducer, controller: "introducer", only: [:show]
          resource :modal, controller: "modal", only: [] do
            get :template
            get :block
          end
        end
      end
      namespace :templates do
        resource :concept_tooltip, only: "show"
      end
    end
  end
end
