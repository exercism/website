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
    resources :concepts, only: %i[index show], controller: "tracks/concepts" do
      member do
        patch :start
        patch :complete
      end
    end

    resources :exercises, only: %i[index show], controller: "tracks/exercises"

    member do
      post :join
    end
  end

  resources :solutions, only: %i[create edit]

  root to: "pages#index"

  # ###############
  # Legacy routes #
  # ###############
  get "solutions/:uuid" => "solutions#legacy_show"
  get "my/solutions/:uuid" => "solutions#legacy_show"
  get "mentor/solutions/:uuid" => "solutions#legacy_show"

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
