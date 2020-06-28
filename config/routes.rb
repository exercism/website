Rails.application.routes.draw do
  root to: "pages#index"

  mount ActionCable.server => '/cable'

  unless Rails.env.production?
    namespace :test do
      namespace :components do
        get 'iterations_summary_table/:id', to: 'iterations_summary_table#index', as: 'iterations_summary_table'
      end
    end
  end
end
