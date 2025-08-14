require 'sidekiq/web'
require 'sidekiq-scheduler/web'

def available_locales_constraint
  (
    I18n.available_locales.map(&:to_s) - ['en']
  ).join("|")
end

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  draw :api
  draw :spi

  # Redirect /en/... -> /... (GET only, preserve query)
  get '/en',        to: redirect('/', status: 301)
  get '/en/*path',  to: redirect(status: 301) { |params, req|
    "/#{params[:path]}#{req.query_string.present? ? "?#{req.query_string}" : ""}"
  }

  ## Website Routes, come in naked or locale versions
  scope '(:locale)', locale: available_locales_constraint do
    draw :website
  end

  draw :special
  draw :bootcamp
end
