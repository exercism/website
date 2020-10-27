Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  # ### #
  # API #
  # ### #
  namespace :api do
    scope :v1 do
      get "ping" => "ping#index"
      get "validate_token" => "validate_token#index"

      resources :tracks, only: %i[index show]
      resources :solutions, only: %i[show update] do
        get :latest, on: :collection

        get 'files/*filepath', to: 'files#show', format: false, as: "file"
        resources :submissions, only: %i[create]
        resources :iterations, only: %i[create]
      end
      resources :submission, only: [] do
        resources :cancellations, only: %i[create], controller: "submissions/cancellations"
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

  # ############ #
  # Normal pages #
  # ############ #

  namespace :maintaining do
    resources :submissions, only: [:index]
  end
  resources :tracks, only: %i[index show] do
    resources :concepts, only: %i[index show], controller: "tracks/concepts"

    resources :exercises, only: %i[index show], controller: "tracks/exercises" do
      member do
        patch :start
        patch :complete
      end

      resources :iterations, only: [:index], controller: "tracks/iterations"
    end

    member do
      post :join
    end
  end

  resources :solutions, only: %i[edit]

  root to: "pages#index"

  # ###############
  # Legacy routes #
  # ###############
  get "solutions/:uuid" => "legacy#solution"
  get "my/solutions/:uuid" => "legacy#solution"
  get "mentor/solutions/:uuid" => "legacy#solution"

  # ########################### #
  # Temporary and testing pages #
  # ########################### #

  namespace :tmp do
    resources :submissions, only: [:create]
    resources :tracks, only: [:create]
  end

  unless Rails.env.production?
    namespace :test do
      namespace :components do
        namespace :student do
          resource :concept_map, only: [:show], controller: 'concept_map'
          resource :editor, only: [:show], controller: "editor"
          resource :tracks_list, only: [:show], controller: "tracks_list" do
            member do
              get 'tracks'
            end
          end
        end
        namespace :maintaining do
          get 'submissions_summary_table', to: 'submissions_summary_table#index', as: 'submissions_summary_table'
        end
        namespace :example do
          get 'submissions_summary_table/:id', to: 'submissions_summary_table#index', as: 'submissions_summary_table'
        end
        namespace :notifications do
          resource :icon, only: %i[show update], controller: "icon"
        end
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
      end
    end
  end
end
