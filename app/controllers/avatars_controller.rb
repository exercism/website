require 'open-uri'

# This should inherit from ActionController::Base, not ApplicationController
class AvatarsController < ActionController::Base # rubocop:disable Rails/ApplicationController
  def show
    # Save a load of testing headaches
    if Rails.env.test?
      return send_data(File.read(Rails.root.join("app", "images", "blank.png")), type: 'image/png', disposition: 'inline')
    end

    user = User.find(params[:id])

    # We don't want future requests to be cached before they should be!
    raise ActiveRecord::RecordNotFound if params[:version].to_i > user.version

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
    send_data data, type: content_type, disposition: 'inline'
  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue StandardError => e
    Bugsnag.notify(e)
    head :internal_server_error
  end
end
