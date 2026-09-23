require_relative '../base_test_case'

class API::Settings::LanguagesControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_settings_language_path, method: :patch

  test "updates the user's locale" do
    setup_user

    patch api_settings_language_path, params: { language: { locale: "hu" } }, headers: @headers, as: :json

    assert_response :ok
    assert_equal "hu", @current_user.reload.data.locale
  end

  test "rejects a locale we do not serve" do
    setup_user

    patch api_settings_language_path, params: { language: { locale: "nl" } }, headers: @headers, as: :json

    assert_response :bad_request
    assert_nil @current_user.reload.data.locale
    assert_equal "invalid_locale", response.parsed_body.dig("error", "type")
  end

  test "rejects a blank locale" do
    setup_user

    patch api_settings_language_path, params: { language: { locale: "" } }, headers: @headers, as: :json

    assert_response :bad_request
  end
end
