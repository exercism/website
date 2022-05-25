require 'sidekiq/web'
require 'sidekiq-scheduler/web'

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

    # TODO: This is just a stub
    resources :users, only: [:update]

    resource :user, only: [] do
      resource :profile_photo, only: %i[destroy], controller: "users/profile_photos"
    end

    resource :profile, only: %i[create destroy]

    resource :journey_overview, only: [:show], controller: "journey_overview"

    scope :v2 do # rubocop:disable Naming/VariableNumber
      get "ping" => "ping#index"
      get "validate_token" => "validate_token#index"
      get "hiring/testimonials" => "hiring#testimonials"

      namespace :donations do
        resource :active_subscription, only: [:show]
        # resources :payments, only: [:create]
        resources :payment_intents, only: [:create] do
          member do
            patch :succeeded
            patch :failed
          end
        end
        resources :subscriptions, only: [] do
          member do
            patch :cancel
            patch :update_amount
          end
        end
      end

      resource :settings, only: [:update] do
        patch :sudo_update
      end
      namespace :settings do
        resource :communication_preferences, only: [:update]

        resources :introducers, only: [], param: :slug do
          patch :hide, on: :member
        end

        resource :auth_token, only: [] do
          patch :reset
        end
      end

      resources :tracks, only: [], controller: "user_tracks", param: :slug do
        resources :solutions_for_mentoring, only: %i[index], controller: "tracks/solutions_for_mentoring"
        member do
          patch :activate_practice_mode
          patch :activate_learning_mode
          patch :reset
          patch :leave
        end
      end

      resources :tracks, only: %i[index show], param: :slug do
        patch 'activate_practice_mode' => "user_tracks#activate_practice_mode"
        patch 'deactivate_practice_mode' => "user_tracks#deactivate_practice_mode"

        resources :exercises, only: %i[index], controller: "exercises", param: :slug do
          member do
            patch :start
          end

          resources :makers, only: [:index], controller: "exercises/makers"
          resources :community_solutions, only: [:index], controller: "community_solutions", param: :handle do
            resource :star, only: %i[create destroy], controller: "community_solution_stars"
            resources :comments, only: %i[index create update destroy], controller: "community_solution_comments", param: :uuid do
              patch :enable, on: :collection
              patch :disable, on: :collection
            end
          end
        end
        resources :concepts, only: [], param: :slug do
          resources :makers, only: [:index], controller: "concepts/makers"
        end
      end

      get "/scratchpad/:category/:title" => "scratchpad_pages#show", as: :scratchpad_page
      patch "/scratchpad/:category/:title" => "scratchpad_pages#update"

      resources :bug_reports, only: %i[create]

      resources :notifications, only: [:index] do
        collection do
          patch :mark_all_as_read
          patch :mark_batch_as_read
          patch :mark_batch_as_unread
        end
      end

      resources :reputation, only: %i[index], param: :uuid do
        patch :mark_all_as_seen, on: :collection
        patch :mark_as_seen, on: :member
      end

      resources :badges, only: %i[index], param: :uuid do
        member do
          patch :reveal
        end
      end

      resources :profiles, only: [], param: :handle do
        get :summary, on: :member

        resources :testimonials, only: %i[index], controller: "profiles/testimonials", param: :uuid
        resources :solutions, only: [:index], controller: 'profiles/solutions'
        resources :contributions, only: [], controller: 'profiles/contributions' do
          collection do
            get :building
            get :maintaining
            get :authoring
            get :other
          end
        end
      end

      resources :contributors, only: [:index]

      resources :tasks, only: [:index]

      resources :docs, only: [:index]

      resources :solutions, only: %i[index show update], param: :uuid do
        member do
          get :diff

          patch :complete
          patch :publish
          patch :unpublish
          patch :published_iteration
          patch :sync
        end

        resources :submissions, only: %i[create], controller: "solutions/submissions", param: :uuid do
          resource :test_run, only: %i[show], controller: "solutions/submission_test_runs" do
            patch :cancel
          end
          resources :files, only: %i[index], controller: "solutions/submission_files"
        end

        resources :iterations, only: %i[create destroy], param: :uuid do
          get :automated_feedback, on: :member
          get :latest_status, on: :collection
        end
        resources :initial_files, only: %i[index], controller: "solutions/initial_files"
        resources :last_iteration_files, only: %i[index], controller: "solutions/last_iteration_files"

        resources :mentor_requests, only: %i[create update], controller: "solutions/mentor_requests", param: :uuid
        resources :discussions, only: %i[index create], controller: "solutions/mentor_discussions", param: :uuid do
          patch :finish, on: :member
          resources :posts, only: %i[index create update destroy], controller: "solutions/mentor_discussion_posts", param: :uuid
        end
      end

      namespace :mentoring do
        resource :registration, only: %i[create], controller: 'registration'
        resource :tracks, only: %i[show update] do
          get :mentored
        end

        resources :requests, only: %i[index], param: :uuid do
          collection do
            get :tracks
            get :exercises
          end
          member do
            patch :lock
            patch :cancel
          end
        end

        resources :discussions, only: %i[index create], param: :uuid do
          member do
            patch :mark_as_nothing_to_do
            patch :finish
          end

          collection do
            get :tracks # TODO: Remove this
          end

          resources :posts, only: %i[index create update destroy], controller: "discussion_posts", param: :uuid
        end

        resources :testimonials, only: %i[index destroy], param: :uuid do
          member do
            patch :reveal
          end
        end

        resources :students, only: [:show], param: :handle do
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
    resource :stripe, only: [:create], controller: "stripe"
    resource :issue_updates, only: [:create]
    resource :membership_updates, only: [:create]
    resource :push_updates, only: [:create]
    resource :pull_request_updates, only: [:create]
    resource :organization_updates, only: [:create]
  end

  # ############ #
  # Normal pages #
  # ############ #
  resource :settings, only: %i[show] do
    get :api_cli
    get :communication_preferences
    get :donations
    patch :reset_account
    delete :destroy_account
  end

  resource :dashboard, only: [:show], controller: "dashboard"

  resources :docs, only: %i[index]
  get 'docs/tracks/:track_slug', to: 'docs#track_index', as: :track_docs
  get 'docs/tracks/:track_slug/*slug', to: 'docs#track_show', as: :track_doc
  get 'docs/tracks', to: 'docs#tracks'
  get 'docs/:section/*slug', to: 'docs#show', as: :doc
  get 'docs/:section', to: 'docs#section', as: :docs_section

  resources :notifications, only: [:index]

  resources :profiles, only: %i[index show new create] do
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
    resources :external_requests, only: [:show], param: :uuid do
      patch :accept, on: :member
    end

    resources :requests, only: [:show], param: :uuid do
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
    resources :site_updates, except: [:destroy]
    resources :contributor_teams, only: %i[index show] do
      resources :memberships, controller: "contributor_teams/memberships", except: [:index]
    end
  end

  namespace :contributing do
    root to: "dashboard#show"
    resources :contributors, only: [:index]
    resources :tasks, only: [:index], param: :uuid do
      get :tooltip, on: :member
    end
  end

  resources :tracks, only: %i[index show] do
    get :about, on: :member

    resources :concepts, only: %i[index show], controller: "tracks/concepts" do
      get :tooltip, on: :member
    end

    resources :exercises, only: %i[index show edit], controller: "tracks/exercises" do
      member do
        get :tooltip
        get :no_test_runner
      end

      resources :iterations, only: [:index], controller: "tracks/iterations"

      resource :mentor_request, only: %i[new show], controller: "tracks/mentor_requests" do
        get :no_slots_remaining
      end
      resources :mentor_discussions, only: %i[index show], controller: "tracks/mentor_discussions"

      resources :solutions, only: %i[index show], controller: "tracks/community_solutions"
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

  # ############ #
  # Unsubscribe  #
  # ############ #
  resource :unsubscribe, only: %i[show update], controller: "unsubscribe"

  # #### #
  # Blog #
  # #### #
  resources :blog_posts, only: %i[index show], path: "blog"

  get "donate" => "donations#index", as: :donate

  # #### #
  # SEO #
  # #### #
  get "robots" => "sitemaps#robots_txt", as: :robots_txt
  get "sitemap" => "sitemaps#index", as: :sitemap
  get "sitemap-general" => "sitemaps#general", as: :sitemap_general
  get "sitemap-profiles" => "sitemaps#profiles", as: :sitemap_profiles
  get "sitemap-tracks-:track_id" => "sitemaps#track", as: :sitemap_track

  root to: "pages#index"

  ##############
  # ELB routes #
  ##############
  get "health-check", to: 'pages#health_check'

  ##########
  # Errors #
  ##########
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"
  get "/503", to: "errors#internal_error"

  ###############
  # About Pages #
  ###############
  resource :about, controller: 'about', only: [:show] do
    get :team
    get :hiring
    get :hiring_content, path: "hiring/content-2", as: :hiring_2
    get :hiring_community, path: "hiring/community-3", as: :hiring_3
    get :hiring_front_end_developer, path: "hiring/front-end-developer-4", as: :hiring_4
    get :hiring_rails_developer, path: "hiring/rails-developer-5", as: :hiring_5
    get :individual_supporters, path: "supporters/individuals", as: :individual_supporters
    get :organisation_supporters, path: "supporters/organisations", as: :organisation_supporters

    %w[packt gobridge].each do |supporter|
      get "supporter_#{supporter}".to_sym, path: "supporters/organisations/#{supporter}", as: "supporter_#{supporter}"
    end
  end

  #########
  # Pages #
  #########
  get "cli-walkthrough" => "pages#cli_walkthrough", as: :cli_walkthrough

  ############
  # Partners #
  ############
  get "partners/gobridge" => "partners#gobridge", as: :gobridge_partner_page
  get "partners/go-developer-network", to: redirect("partners/gobridge")
  get "partners/gdn", to: redirect("partners/gobridge")

  get "site.webmanifest" => "meta#site_webmanifest"

  #################
  # Legacy routes #
  #################
  get "solutions/:uuid" => "legacy#solution"
  get "my/solutions/:uuid" => "legacy#my_solution"
  get "mentor/solutions/:uuid" => "legacy#mentor_solution"

  %i[installation learning resources tests].each do |doc|
    get "tracks/:slug/#{doc}", to: redirect("docs/tracks/%{slug}/#{doc}") # rubocop:disable Style/FormatStringToken
  end

  get "values", to: redirect("about")
  get "team", to: redirect("about/team")
  get "team/staff", to: redirect("team")
  get "team/staff", to: redirect("contributors")

  get "team/contributors", to: redirect("contributing/contributors")
  get "team/mentors", to: redirect("contributing/contributors?category=mentoring")
  get "team/maintainers", to: redirect("contributing/contributors?category=maintaining")

  get "terms-of-service", to: redirect("docs/using/legal/terms-of-service")
  get "privacy-policy", to: redirect("docs/using/legal/privacy-policy")
  get "cookie-policy", to: redirect("docs/using/legal/cookie-policy")
  get "code-of-conduct", to: redirect("docs/using/legal/code-of-conduct"), as: :code_of_conduct
  get "accessibility", to: redirect("docs/using/legal/accessibility")
  get "contact", to: redirect("docs/using/contact")
  get "cli", to: redirect("docs/using/solving-exercises/working-locally")
  get "report-abuse", to: redirect("docs/using/report-abuse")
  get "become-a-mentor", to: redirect("mentoring")
  get "my/settings", to: redirect("settings")
  get "my/tracks", to: redirect("tracks")
  get "getting-started", to: redirect("docs/using/getting-started")
  get '/languages/:slug', to: redirect('/tracks/%{slug}') # rubocop:disable Style/FormatStringToken
  get "contribute", to: redirect("contributing")

  # Licences
  %w[licence license].each do |spelling|
    get "#{spelling}s/cc-sa-4", to: redirect("docs/using/licenses/cc-by-nc-sa"), as: "cc_sa_4_#{spelling}"
    get "#{spelling}s/cc-by-nc-sa-4", to: redirect("docs/using/licenses/cc-by-nc-sa"), as: "cc_by_nc_sa_4_#{spelling}"
    get "#{spelling}s/mit", to: redirect("docs/using/licenses/mit"), as: "mit_#{spelling}"
    get "#{spelling}s/agpl", to: redirect("docs/using/licenses/agpl"), as: "agpl_#{spelling}"
  end

  # ########################### #
  # Temporary and testing pages #
  # ########################### #

  unless Rails.env.production?
    # TODO: Remove these before launching
    namespace :temp do
      resources :tracks, only: [:create]
      resource :user_deletion, only: [:show]
      resource :user_reset, only: [:show]

      resources :user_tracks, only: [] do
        get :practice_mode, on: :member
        get :reset, on: :member
        get :leave, on: :member
      end
      resources :modals, only: [] do
        collection do
          get :mentoring_sessions
          get :publish_exercise
          get :completed_exercise
          get :completed_mentoring_1
          get :welcome_to_v3 # rubocop:disable Naming/VariableNumber
          get :reputation
          get :mentoring_dropdown
          get :exercise_tooltip
          get :select_exercise_for_mentoring
          get :badge
          get :donation_confirmation
        end
      end
      resource :mentoring, only: [], controller: "mentoring" do
        get :student_request
      end
      resource :mentored_tracks, only: %i[show update]
    end

    namespace :test do
      namespace :misc do
        resource :loading_overlay, only: [:show], controller: "loading_overlay"
      end
      namespace :components do
        namespace :student, param: :handle do
          resource :concept_map, only: [:show], controller: 'concept_map'
        end
        namespace :maintaining do
          get 'submissions_summary_table', to: 'submissions_summary_table#index', as: 'submissions_summary_table'
        end
        namespace :tooltips do
          resource :tooltip, controller: "tooltip", only: [:show] do
            get 'user_summary/:id', to: 'tooltip#user_summary', as: 'user_summary'
          end
        end
        namespace :common do
          resource :site_updates_list, controller: "site_updates_list", only: [:show]
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
