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

  draw(:api)
  draw(:spi)

  # English is naked: /en/tracks redirects to /tracks
  get "/en", to: redirect("/", status: 301)
  get "/en/*path", format: false, to: redirect(status: 301) { |params, req|
    ["/#{params[:path]}", req.query_string.presence].compact.join("?")
  }

  # The locale is an optional path prefix, matched against the roster.
  # Whether a given visitor may see a given locale is LocaleRouting's job.
  scope "(:locale)", constraints: { locale: LocaleRoster.route_constraint } do
    draw(:website)
  end

  draw(:website_en)
  draw(:special)
  draw(:bootcamp)
end
