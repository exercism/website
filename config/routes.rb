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
    resources :iterations, only: [:index]
  end
  resources :tracks, only: %i[index show] do
    member do
      post :join
    end
  end

  root to: "pages#index"

  # ########################### #
  # Temporary and testing pages #
  # ########################### #

  namespace :tmp do
    resources :iterations, only: [:create]
    resources :tracks, only: [:create]
  end

  unless Rails.env.production?
    namespace :test do
      namespace :components do
        namespace :student do
          resource :track_list, only: [:show], controller: "track_list"
        end
        namespace :maintaining do
          get 'iterations_summary_table', to: 'iterations_summary_table#index', as: 'iterations_summary_table'
        end
        namespace :example do
          get 'iterations_summary_table/:id', to: 'iterations_summary_table#index', as: 'iterations_summary_table'
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
