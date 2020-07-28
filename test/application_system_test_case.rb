require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :selenium, using: :headless_chrome do |driver_option|
    # Without this argument, Chrome cannot be started in Docker
    driver_option.add_argument('no-sandbox')
  end
end
