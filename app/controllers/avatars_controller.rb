require 'open-uri'

class AvatarsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_onboarded!
  skip_before_action :verify_authenticity_token
  skip_after_action :set_body_class_header
  skip_around_action :mark_notifications_as_read!
  skip_after_action :updated_last_visited_on!

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
  end
end
