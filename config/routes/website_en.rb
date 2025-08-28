##############
# Challenges #
##############

resources :challenges, only: [:show] do
  post :start, on: :member
  get :implementation_status, on: :member
  get "implementation_status/:track_slug" => "challenges#track_implementation_status", on: :member, as: :track_implementation_status
end
