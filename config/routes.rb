Rails.application.routes.draw do
  root to: "pages#index"
  
  mount ActionCable.server => '/cable'
end
