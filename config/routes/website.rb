# #### #
# Auth #
# #### #

# We handle omniauth callbacks in special.rb where they're not scoped by locale.
devise_for :users, skip: :omniauth_callbacks, controllers: {
  sessions: "auth/sessions",
  registrations: "auth/registrations",
  confirmations: "auth/confirmations",
  passwords: "auth/passwords"
}

devise_scope :user do
  get "confirmations/required" => "auth/confirmations#required", as: "auth_confirmation_required"
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
  get :insiders
  patch :reset_account
  delete :destroy_account
  delete :disconnect_discord

  resource :github_syncer, only: %i[show update destroy], controller: "settings/github_syncer" do
    get :callback # For GitHub installation callback
    patch :sync_everything
    patch :sync_track
    patch :sync_solution
    patch :sync_iteration
  end
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
  resources :track_maintainers, only: %i[index create]
  resources :track_categories, only: %i[index create]
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

resources :favorites, only: [:index]

namespace :localization do
  root to: "dashboard#show"
  resources :originals, only: %i[index show] do
  end
  resources :glossary_entries, only: %i[index show] do
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
resource :unsubscribe, only: %i[show update], controller: "unsubscribe" do
  patch :all
  get :easy_all, action: "all"
end

# #### #
# Blog #
# #### #
resources :blog_posts, only: %i[index show], path: "blog"

get "donate" => "donations#index", as: :donate
get "donated" => "donations#donated", as: :donated

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
# Pages #
#########
get "cli-walkthrough" => "pages#cli_walkthrough", as: :cli_walkthrough

############
# Partners #
############
get "partners/gobridge" => "partners#gobridge", as: :gobridge_partner_page

###################
# Adverts & Perks #
###################
resources :partners, only: [:show]
resources :perks, only: %i[index]

get "/courses" => "courses#index"

get "/courses/testimonials" => "courses#testimonials"
get "/courses/enrolled" => "courses#enrolled", as: :courses_enrolled
get "/courses/:id" => "courses#show", as: :course

get "/courses/:id/enroll" => "courses#start_enrolling", as: :course_start_enrolling
post "/courses/:id/enroll" => "courses#enroll", as: :course_enroll
get "/courses/:id/pay" => "courses#pay", as: :course_pay

post "/courses/stripe/create-checkout-session" => "courses#stripe_create_checkout_session", as: :courses_stripe_create_checkout_session
get "/courses/stripe/session-status" => "courses#stripe_session_status", as: :courses_stripe_session_status

#########
# Other #
#########
namespace :localization do
  resource :translator, only: %i[new create]
end

root to: "pages#index"
