require 'open-uri'

# This should inhert from a name ActionController::Base, not ApplicationController
class AvatarsController < ActionController::Base # rubocop:disable Rails/ApplicationController
  def show
    user = User.find(params[:id])

    if user.avatar.attached?
      data = user.avatar.download
      content_type = user.avatar.content_type
    else
      url = user.attributes['avatar_url'].presence || "#{Exercism.config.website_icons_host}/placeholders/user-avatar.svg"

      file = URI.parse(url).open
      data = file.read
      content_type = file.content_type
    end

    expires_in 5.years, public: true
    response.set_header("Content-Type", content_type)

    send_data data,
      type: content_type,
      disposition: 'inline'
  rescue ActiveRecord::RecordNotFound
    head :resource_not_found
  end
end
