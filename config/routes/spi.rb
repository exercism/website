# ### #
# SPI #
# ### #
namespace :spi do
  resources :tooling_jobs, only: :update
  get "solution_image_data/:track_slug/:exercise_slug/:user_handle" => "solution_image_data#show"
  get "profile_image_data/:user_handle" => "profile_image_data#show"
  patch "unsubscribe_user" => "unsubscribe_users#unsubscribe_by_email", as: "unsubscribe_user"
end
