class MetaController < ApplicationController
  skip_before_action :authenticate_user!

  def apple_developer_merchantid_domain_association
    render layout: false
  end

  def site_webmanifest
    expires_in 1.day, public: true

    render json: {
      "name": "Exercism",
      "short_name": "Exercism",
      "icons": [
        {
          "src": "#{Exercism.config.website_icons_host}/meta/android-chrome-192x192.png",
          "sizes": "192x192",
          "type": "image/png"
        },
        {
          "src": "#{Exercism.config.website_icons_host}/meta/android-chrome-512x512.png",
          "sizes": "512x512",
          "type": "image/png"
        }
      ],
      "theme_color": "#ffffff",
      "background_color": "#ffffff",
      "display": "standalone"
    }
  end
end
