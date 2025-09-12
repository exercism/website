# ### #
# SPI #
# ### #
namespace :spi do
  resources :tooling_jobs, only: :update
  resources :chatgpt_responses, only: :create
  get "solution_image_data/:track_slug/:exercise_slug/:user_handle" => "solution_image_data#show"
  patch "unsubscribe_user" => "unsubscribe_users#unsubscribe_by_email", as: "unsubscribe_user"

  %w[
    rate_limited
    errored

    localization_verify_translation_proposal
    localization_verify_glossary_entry_proposal
    localization_translated
  ].each do |action|
    post "llm/#{action}" => "llm_responses##{action}", as: action
  end
end
