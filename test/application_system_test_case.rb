require "test_helper"
require_relative "./support/websockets_helpers"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include WebsocketsHelpers
  # Devise::Test::IntegrationHelpers

  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :selenium, using: :headless_chrome do |driver_option|
    # Without this argument, Chrome cannot be started in Docker
    driver_option.add_argument('no-sandbox')
  end

  def sign_in!(user = nil)
    @current_user = user || create(:user)

    # TODO: Renable when adding devise
    # @current_user.confirm
    # sign_in @current_user
  end
end
