require_relative './base_test_case'

class API::SettingsControllerTest < API::BaseTestCase
  ###
  # SUDO_UPDATE
  ###
  test "sudo_update is rate limited" do
    setup_user

    beginning_of_minute = Time.current.beginning_of_minute
    travel_to beginning_of_minute

    8.times do
      patch sudo_update_api_settings_path(user: { sudo_password: 'password' }), headers: @headers, as: :json
      assert_response :ok
    end

    patch sudo_update_api_settings_path(user: { sudo_password: 'password' }), headers: @headers, as: :json
    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to beginning_of_minute + 1.minute

    patch sudo_update_api_settings_path(user: { sudo_password: 'password' }), headers: @headers, as: :json
    assert_response :ok
  end

  ###
  # UPDATE
  ###
  test "update saves linkedin" do
    setup_user
    create(:user_profile, user: @current_user)

    patch api_settings_path(profile: { linkedin: "www.linkedin.com/in/foo" }), headers: @headers, as: :json

    assert_response :ok
    assert_equal "https://www.linkedin.com/in/foo", @current_user.profile.reload.linkedin
  end

  test "update returns errors for an invalid linkedin" do
    setup_user
    create(:user_profile, user: @current_user)

    patch api_settings_path(profile: { linkedin: "ftp://linkedin.com/in/foo" }), headers: @headers, as: :json

    assert_response :bad_request
    expected = {
      error: {
        type: "failed_validations",
        message: I18n.t("api.errors.failed_validations"),
        errors: [[{ linkedin: ["is invalid"] }]]
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
    assert_nil @current_user.profile.reload.linkedin
  end
end
