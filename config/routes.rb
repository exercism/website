Rails.application.routes.draw do
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
