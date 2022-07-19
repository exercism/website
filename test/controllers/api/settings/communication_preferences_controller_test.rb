require_relative '../base_test_case'

class API::Settings::CommunicationPreferencesControllerTest < API::BaseTestCase
  ###
  # UPDATE
  ###
  test "update is rate limited" do
    setup_user

    beginning_of_minute = Time.current.beginning_of_minute
    travel_to beginning_of_minute

    communication_preferences = { receive_product_updates: false }

    8.times do
      patch api_settings_communication_preferences_path(communication_preferences:), headers: @headers, as: :json
      assert_response :ok
    end

    patch api_settings_communication_preferences_path(communication_preferences:), headers: @headers, as: :json
    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to beginning_of_minute + 1.minute

    patch api_settings_communication_preferences_path(communication_preferences:), headers: @headers, as: :json
    assert_response :ok
  end
end
