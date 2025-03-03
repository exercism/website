namespace :bootcamp do
  get "dashboard", to: "dashboard#index", as: :dashboard
  get "faqs", to: "pages#faqs", as: :faqs
  resources "levels", param: :idx, only: %i[index show]
  resources "concepts", param: :slug, only: %i[index show]
  resources "projects", param: :slug, only: %i[index show] do
    resources "exercises", param: :slug, only: %i[show edit]
  end
  resources "exercises", param: :slug, only: %i[index]
  resources "drawings", param: :uuid, only: %i[create edit]
  resources "custom_functions", param: :short_name, only: %i[create index edit]

  namespace :admin do
    resource :settings, only: [:show] do
      post :increment_level, on: :collection
    end
    resources :exercises
  end
end

# namespace :api do
#   resources :solutions, param: :uuid, only: [] do
#     member do
#       patch :complete
#     end
#     resources :submissions, param: :uuid, only: [:create]
#   end
# end
