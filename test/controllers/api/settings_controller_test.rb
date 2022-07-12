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
  end
end
