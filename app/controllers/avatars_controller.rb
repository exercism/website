require 'open-uri'

# This should inherit from ActionController::Base, not ApplicationController
class AvatarsController < ActionController::Base # rubocop:disable Rails/ApplicationController
  before_action :set_nosniff_header

  def show
    # Save a load of testing headaches
    if Rails.env.test?
      return send_data(File.read(Rails.root.join("app", "images", "blank.png")), type: 'image/png', disposition: 'inline')
    end

    user = User.find(params[:id])

    # We don't want future requests to be cached before they should be!
    raise ActiveRecord::RecordNotFound if params[:version].to_i > user.version

    data, content_type = User::RetrieveAvatar.(user)

    expires_in 5.years, public: true
    response.set_header("Content-Type", content_type)
    send_data data, type: content_type, disposition: 'inline'
  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue OpenURI::HTTPError
    file = URI.parse(User::RetrieveAvatar.placeholder_url).open
    expires_in 5.minutes, public: true
    send_data file.read, type: file.content_type, disposition: 'inline'
  rescue StandardError => e
    Sentry.capture_exception(e)
    head :internal_server_error
  end

  private
  def set_nosniff_header
    response.set_header("X-Content-Type-Options", "nosniff")
  end
end
