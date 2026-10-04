require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end
  mount ActionCable.server => '/cable'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # GET and DELETE are routed too so the MCP transport can answer them per the spec
  match "mcp", to: "mcp#handle", via: %i[get post delete], as: :mcp

  draw(:api)
  draw(:spi)

  get "/en", to: redirect("/", status: 301)
  get "/en/*path", format: false, to: redirect(status: 301) { |params, req|
    ["/#{params[:path]}", req.query_string.presence].compact.join("?")
  }

  scope "(:locale)", constraints: { locale: LOCALE_ROUTE_CONSTRAINT } do
    draw(:website)
  end

  draw(:website_en)
  draw(:special)
  draw(:bootcamp)
end
