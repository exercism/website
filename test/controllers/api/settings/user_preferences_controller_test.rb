require_relative '../base_test_case'

class API::Settings::UserPreferencesControllerTest < API::BaseTestCase
  ###
  # UPDATE
  ###
  test "update is rate limited" do
    setup_user

    beginning_of_minute = Time.current.beginning_of_minute
    travel_to beginning_of_minute

    user_preferences = {
      auto_update_exercises: false,
      allow_comments_by_default: false
    }

    20.times do
      patch api_settings_user_preferences_path(user_preferences:), headers: @headers, as: :json
      assert_response :ok
    end

    patch api_settings_user_preferences_path(user_preferences:), headers: @headers, as: :json
    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to beginning_of_minute + 1.minute

    patch api_settings_user_preferences_path(user_preferences:), headers: @headers, as: :json
    assert_response :ok
  end
end
