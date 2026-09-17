# Pages that exist in English only. They are never locale-scoped, and
# LocaleRouting never redirects a user onto them with a prefix.

##############
# Challenges #
##############
resources :challenges, only: [:show] do
  post :start, on: :member
  get :implementation_status, on: :member
  get "implementation_status/:track_slug" => "challenges#track_implementation_status", on: :member, as: :track_implementation_status
end
