require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  draw(:api)
  draw(:spi)

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

  get "discourse/sso" => "discourse/sso"

  # ######## #
  # Webhooks #
  # ######## #
  namespace :webhooks do
    resource :stripe, only: [:create], controller: "stripe"
    resource :paypal, only: [:create], controller: "paypal" do
      post :ipn
    end
    resource :coinbase, only: [:create], controller: "coinbase"
    resource :github_sponsors, only: [:create]

    resource :issue_updates, only: [:create]
    resource :membership_updates, only: [:create]
    resource :push_updates, only: [:create]
    resource :pull_request_updates, only: [:create]
    resource :organization_updates, only: [:create]
    resource :workflow_run_updates, only: [:create]
  end

  # ##### #
  # Admin #
  # ##### #
  namespace :admin do
    root to: "dashboard#show"
    resources :insiders, controller: 'insiders'
    resources :community_videos
    resources :partners do
      resources :adverts
      resources :perks
    end
    resources :mailshots do
      member do
        patch :send_test
        patch :send_to_audience
      end
    end
    resources :streaming_events
    resources :donors, only: %i[index new create]
    resources :users, only: %i[index] do
      collection do
        get :search
      end
    end
  end

  # ############ #
  # Normal pages #
  # ############ #
  resource :settings, only: %i[show] do
    get :api_cli
    get :user_preferences
    get :communication_preferences
    get :donations
    get :integrations
    patch :reset_account
    delete :destroy_account
    delete :disconnect_discord
  end

  resource :dashboard, only: [:show], controller: "dashboard"

  resources :docs, only: %i[index]
  get 'docs/tracks/:track_slug', to: 'docs#track_index', as: :track_docs
  get 'docs/tracks/:track_slug/*slug', to: 'docs#track_show', as: :track_doc
  get 'docs/tracks', to: 'docs#tracks'
  get 'docs/:section/*slug', to: 'docs#show', as: :doc
  get 'docs/:section', to: 'docs#section', as: :docs_section

  resources :notifications, only: [:index]

  resources :impact, only: [:index]

  resources :solution_tagger, only: [:index]

  resource :images, controller: "images" do
    get "solutions/:track_slug/:exercise_slug/:user_handle", to: "images#solution"
    get "profiles/:user_handle", to: "images#profile"
  end

  resource :insiders, only: [:show], controller: "insiders" do
    get :payment_pending
  end

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
    resources :automation, only: %i[index edit], param: :uuid do
      collection do
        get :with_feedback
        get :admin
        get :tooltip_locked
      end
    end
  end

  namespace :maintaining do
    root to: "dashboard#show"
    resources :submissions, only: [:index]
    resources :exercise_representations
    resources :site_updates, except: [:destroy]
  end

  namespace :contributing do
    root to: "dashboard#show"
    resources :contributors, only: [:index]
    resources :tasks, only: [:index], param: :uuid do
      get :tooltip, on: :member
    end
  end
  namespace :training_data do
    root to: "dashboard#index"

    get "external" => "external#index"
    patch "become_trainer" => "external#become_trainer"

    resources :code_tags_samples, only: %i[index show] do
      get :next, on: :collection
    end
  end

  resource :community, only: %i[show], controller: "community"

  namespace :community do
    resources :stories, only: %i[index show]
    resources :videos, only: %i[index show]
    resources :brief_introductions, only: %i[index]
    resources :interviews, only: %i[index]
  end

  resources :tracks, only: %i[index show] do
    get :about, on: :member

    resource :build, only: %i[show], controller: "tracks/build" do
      get :syllabus_tooltip
      get :representer_tooltip
      get :analyzer_tooltip
      get :test_runner_tooltip
      get :practice_exercises_tooltip
    end

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
        get :get_more_slots
      end
      resources :mentor_discussions, only: %i[index show], controller: "tracks/mentor_discussions" do
        collection do
          get :tooltip_locked
        end
      end
      resources :solutions, only: %i[index show], controller: "tracks/community_solutions" do
        collection do
          get :tooltip_locked
        end
      end

      resources :articles, only: %i[index show], controller: "tracks/articles"
      resources :approaches, only: %i[index show], controller: "tracks/approaches"

      resource :dig_deeper, only: %i[show], controller: "tracks/dig_deeper" do
        get :tooltip_locked
      end
    end

    member do
      post :join
    end
  end
  resources :exercises, only: %i[show], controller: "generic_exercises", as: :generic_exercises do
    member do
      get :approaches
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

  resources :challenges, only: [:show] do
    post :start, on: :member
    get :implementation_status, on: :member
    get "implementation_status/:track_slug" => "challenges#track_implementation_status", on: :member, as: :track_implementation_status
  end

  # ############ #
  # Unsubscribe  #
  # ############ #
  resource :unsubscribe, only: %i[show update], controller: "unsubscribe" do
    patch :all
  end

  # #### #
  # Blog #
  # #### #
  resources :blog_posts, only: %i[index show], path: "blog"

  get "donate" => "donations#index", as: :donate
  get "donated" => "donations#donated", as: :donated

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

  ###################
  # Adverts & Perks #
  ###################
  resources :adverts, controller: "partner/adverts", only: [] do
    get :redirect, on: :member
  end
  resources :perks, only: %i[index show] do
    get :claim, on: :member
  end

  ###############
  # About Pages #
  ###############
  resource :about, controller: 'about', only: [:show] do
    resources :partners, only: %i[index show], path: "supporters/organisations", controller: "about/partners"

    get :impact
    get :testimonials
    get :team
    get :hiring
    get :hiring_content, path: "hiring/content-2", as: :hiring_2
    get :hiring_community, path: "hiring/community-3", as: :hiring_3
    get :hiring_front_end_developer, path: "hiring/front-end-developer-4", as: :hiring_4
    get :hiring_rails_developer, path: "hiring/rails-developer-5", as: :hiring_5
    get :individual_supporters, path: "supporters/individuals", as: :individual_supporters
    # get :organisation_supporters, path: "supporters/organisations", as: :organisation_supporters

    # %w[packt gobridge].each do |supporter|
    #   get "supporter_#{supporter}".to_sym, path: "supporters/organisations/#{supporter}", as: "supporter_#{supporter}"
    # end
  end

  #########
  # Cohorts #
  #########
  resources :cohorts, only: [:show] do
    post :join, on: :member
  end

  #########
  # Pages #
  #########
  get "cli-walkthrough" => "pages#cli_walkthrough", as: :cli_walkthrough

  ############
  # Partners #
  ############
  get "partners/gobridge" => "partners#gobridge", as: :gobridge_partner_page
  get "partners/code-capsules/advert_redirect" => "partners#code_capsules_advert_redirect"
  get "partners/go-developer-network", to: redirect("partners/gobridge")
  get "partners/gdn", to: redirect("partners/gobridge")

  ##################
  # Special routes #
  ##################
  get "site.webmanifest" => "meta#site_webmanifest"
  get ".well-known/apple-developer-merchantid-domain-association" => "meta#apple_developer_merchantid_domain_association"
  get "avatars/:id/:version" => "avatars#show"

  #################
  # Legacy routes #
  #################
  get "solutions/:uuid" => "legacy#solution"
  get "my/solutions/:uuid" => "legacy#my_solution"
  get "mentor/solutions/:uuid" => "legacy#mentor_solution"

  %i[installation learning resources tests].each do |doc|
    get "tracks/:slug/#{doc}", to: redirect("docs/tracks/%{slug}/#{doc}")
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
  get '/languages/:slug', to: redirect('/tracks/%{slug}')
  get "contribute", to: redirect("contributing")
  get "faqs", to: redirect("docs/using/faqs")

  get "r/discord", to: redirect("https://discord.gg/ph6erP7P7G"), as: :discord_redirect
  get "r/twitter", to: redirect("https://twitter.com/exercism_io"), as: :twitter_redirect
  get "r/youtube", to: redirect("https://youtube.com/@exercism_org"), as: :youtube_redirect
  get "r/twitch", to: redirect("https://twitch.tv/exercismlive"), as: :twitch_redirect
  get "r/youtube-community", to: redirect("https://youtube.com/@ExercismCommunity"), as: :youtube_community_redirect
  get "r/forum", to: redirect("https://forum.exercism.org"), as: :forum_redirect
  get "r/t", to: redirect("/about/testimonials"), as: :testimonials_redirect

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
