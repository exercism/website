# ### #
# SPI #
# ### #
namespace :spi do
  resources :tooling_jobs, only: :update
  resources :chatgpt_responses, only: :create
  get "solution_image_data/:track_slug/:exercise_slug/:user_handle" => "solution_image_data#show"
end
