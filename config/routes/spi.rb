# ### #
# SPI #
# ### #
# These routes only answer on the internal SPI host.
constraints(->(request) { request.host == URI(Exercism.config.spi_url).host }) do
  namespace :spi do
    resources :tooling_jobs, only: :update
    get "solution_image_data/:track_slug/:exercise_slug/:user_handle" => "solution_image_data#show"
    get "profile_image_data/:user_handle" => "profile_image_data#show"
    patch "unsubscribe_user" => "unsubscribe_users#unsubscribe_by_email", as: "unsubscribe_user"
  end
end
