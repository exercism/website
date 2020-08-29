Rails.application.routes.draw do
  # ### #
  # API #
  # ### #
  namespace :api do
    scope :v1 do
      get "ping" => "ping#index"
      get "validate_token" => "validate_token#index"

      # resource :cli_settings, only: [:show]
      # resources :tracks, only: [:show]
      resources :solutions, only: %i[show update] do
        collection do
          get :latest
        end

        # get 'files/*filepath', to: 'files#show', format: false, as: "file"
      end
    end
  end
  get "api/(*url)", to: 'api/errors#render_404'

  root to: "pages#index"

  mount ActionCable.server => '/cable'
  namespace :spi do
    resources :tooling_jobs, only: :update
  end

  namespace :maintaining do
    resources :iterations, only: [:index]
  end

  namespace :tmp do
    resources :iterations, only: [:create]
    resources :tracks, only: [:create]
  end

  resources :tracks, only: %i[index show]

  unless Rails.env.production?
    namespace :test do
      namespace :components do
        namespace :maintaining do
          get 'iterations_summary_table', to: 'iterations_summary_table#index', as: 'iterations_summary_table'
        end
        namespace :example do
          get 'iterations_summary_table/:id', to: 'iterations_summary_table#index', as: 'iterations_summary_table'
        end
      end
    end
  end
end
