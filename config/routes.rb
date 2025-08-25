require 'sidekiq/web'
require 'sidekiq-scheduler/web'

# Build a safe, anchored regex like: /\A(?:en|hu|pt-BR)\z/
def available_locales_regex
  union = Regexp.union(I18n.available_locales.map(&:to_s)) # handles hyphens safely
  /(?:#{union.source})/
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
  scope '(:locale)', constraints: { locale: available_locales_regex } do
    draw :website
  end

  draw :special
  draw :bootcamp
end
