# ###### #
# Devise #
# ###### #

# We have to extract the omniauth callbacks to not be scoped under locale
devise_for :users, only: :omniauth_callbacks, controllers: {
  omniauth_callbacks: "auth/omniauth_callbacks"
}

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

# #### #
# SEO #
# #### #
get "robots" => "sitemaps#robots_txt", as: :robots_txt
get "sitemap" => "sitemaps#index", as: :sitemap
get "sitemap-general" => "sitemaps#general", as: :sitemap_general
get "sitemap-profiles" => "sitemaps#profiles", as: :sitemap_profiles
get "sitemap-tracks-:track_id" => "sitemaps#track", as: :sitemap_track

get "ihid", to: 'pages#ihid'
get "javascript-browser-test-runner-worker.mjs", to: 'pages#javascript_browser_test_runner_worker'
get "javascript-i18n/:git_sha/:locale.js", to: 'pages#javascript_i18n', as: :javascript_i18n
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
resources :perks, only: %i[] do
  get :claim, on: :member
end

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

# Licences
%w[licence license].each do |spelling|
  get "#{spelling}s/cc-sa-4", to: redirect("docs/using/licenses/cc-by-nc-sa"), as: "cc_sa_4_#{spelling}"
  get "#{spelling}s/cc-by-nc-sa-4", to: redirect("docs/using/licenses/cc-by-nc-sa"), as: "cc_by_nc_sa_4_#{spelling}"
  get "#{spelling}s/mit", to: redirect("docs/using/licenses/mit"), as: "mit_#{spelling}"
  get "#{spelling}s/agpl", to: redirect("docs/using/licenses/agpl"), as: "agpl_#{spelling}"
end

#############
# Redirects #
#############
get "partners/code-capsules/advert_redirect" => "partners#code_capsules_advert_redirect"
get "partners/go-developer-network", to: redirect("partners/gobridge")
get "partners/gdn", to: redirect("partners/gobridge")

get "r/discord", to: redirect("https://discord.gg/ph6erP7P7G"), as: :discord_redirect
get "r/twitter", to: redirect("https://twitter.com/exercism_io"), as: :twitter_redirect
get "r/youtube", to: redirect("https://youtube.com/@exercism_org"), as: :youtube_redirect
get "r/twitch", to: redirect("https://twitch.tv/exercismlive"), as: :twitch_redirect
get "r/youtube-community", to: redirect("https://youtube.com/@ExercismCommunity"), as: :youtube_community_redirect
get "r/forum", to: redirect("https://forum.exercism.org"), as: :forum_redirect
get "r/t", to: redirect("/about/testimonials"), as: :testimonials_redirect
get "/bootcamp" => "courses#course_redirect", as: :bootcamp

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
