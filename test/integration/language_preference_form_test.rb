require "test_helper"

class LanguagePreferenceFormTest < ActionDispatch::IntegrationTest
  test "the form is on the unprefixed page, even when reached through a localised url" do
    sign_in!

    get "/hu/settings/user_preferences"
    assert_redirected_to "/settings/user_preferences"

    follow_redirect!
    assert_response :ok
    assert_select "div[data-react-id=?]", "settings-language-preference-form"
  end

  test "saving a language renders the same unprefixed page in it" do
    user = create :user
    sign_in!(user)

    patch api_settings_language_path, params: { language: { locale: "hu" } }, as: :json
    assert_response :ok

    get "/settings/user_preferences"
    assert_response :ok
    assert_select "html[lang=hu]"
  end
end
