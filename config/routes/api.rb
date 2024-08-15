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

  resource :user, only: %i[show update] do
    patch :activate_insiders
    resource :profile_photo, only: %i[destroy], controller: "users/profile_photos"
  end

  resource :profile, only: %i[create destroy]
  resources :watched_videos, only: :create

  resource :journey_overview, only: [:show], controller: "journey_overview"

  scope :v2 do
    get "ping" => "ping#index"
    get "validate_token" => "validate_token#index"
    get "hiring/testimonials" => "hiring#testimonials"

    namespace :payments do
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
          patch :update_plan
        end

        get :current, on: :collection
      end
    end

    resource :settings, only: [:update] do
      patch :sudo_update
    end
    namespace :settings do
      resource :user_preferences, only: [:update] do
        patch :enable_solution_comments
        patch :disable_solution_comments
      end
      resource :communication_preferences, only: [:update]

      resources :introducers, only: [], param: :slug do
        patch :hide, on: :member
      end

      resource :auth_token, only: [] do
        patch :reset
      end
    end

    resources :tracks, only: [], controller: "user_tracks", param: :slug do
      resources :tags, only: %i[], controller: "tracks/tags", param: :tag do
        member do
          post :filterable, constraints: { tag: %r{[^/]+} }
          delete :filterable, to: 'tracks/tags#not_filterable', as: "not_filterable", constraints: { tag: %r{[^/]+} }
          post :enabled, constraints: { tag: %r{[^/]+} }
          delete :enabled, to: 'tracks/tags#not_enabled', as: "not_enabled", constraints: { tag: %r{[^/]+} }
        end
      end

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

        resources :export_solutions, only: [:index]
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
      resources :trophies, only: [:index], param: :uuid, controller: "tracks/trophies" do
        member do
          patch :reveal
        end
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

    resources :streaming_events, only: [:index]

    resources :solutions, only: %i[index show update], param: :uuid do
      member do
        get :diff

        patch :complete
        patch :publish
        patch :unpublish
        patch :published_iteration
        patch :sync
        patch :unlock_help
      end

      resources :submissions, only: %i[create], controller: "solutions/submissions", param: :uuid do
        resource :ai_help, only: %i[create], controller: "solutions/submission_ai_help"
        resource :test_run, only: %i[show], controller: "solutions/submission_test_runs" do
          patch :cancel
        end
        resources :files, only: %i[index], controller: "solutions/submission_files"
      end

      resources :iterations, only: %i[create destroy], param: :uuid do
        get :automated_feedback, on: :member
        get :latest, on: :collection
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

      resources :representations, only: %i[update], param: :uuid do
        collection do
          get :with_feedback
          get :without_feedback
          get :admin
        end
      end

      resources :requests, only: %i[index], param: :uuid do
        collection do
          get :tracks
          get :exercises
        end
        member do
          patch :lock
          patch :extend_lock
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

    namespace :metrics do
      get 'periodic', to: "periodic#index"
    end

    namespace :impact do
      resources :testimonials, only: %i[index], param: :uuid
    end

    resources :community_videos, only: %i[index create] do
      get :lookup, on: :collection
    end

    resources :community_stories, only: %i[index]

    namespace :training_data do
      resources :code_tags_samples, only: %i[index] do
        member do
          patch :update_tags
        end
      end
    end

    post "markdown/parse" => "markdown#parse", as: "parse_markdown"
  end
end
get "api/(*url)", to: 'api/errors#render_404'
