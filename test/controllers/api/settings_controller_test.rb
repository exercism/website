require_relative './base_test_case'

class API::SettingsControllerTest < API::BaseTestCase
  ###
  # SUDO_UPDATE
  ###
  test "sudo_update is rate limited" do
    setup_user

    8.times do
      patch sudo_update_api_settings_path(user: { sudo_password: 'password' }), headers: @headers, as: :json
      assert_response :success
    end

    patch sudo_update_api_settings_path(user: { sudo_password: 'password' }), headers: @headers, as: :json
    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to Time.current + 1.minute

    patch sudo_update_api_settings_path(user: { sudo_password: 'password' }), headers: @headers, as: :json
    assert_response :success
  end
end
