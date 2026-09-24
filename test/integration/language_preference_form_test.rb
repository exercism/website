require "test_helper"

class LanguagePreferenceFormTest < ActionDispatch::IntegrationTest
  # A locale in the path outranks the saved preference.
  test "each language carries the current page's path in that locale" do
    sign_in!

    get "/settings/user_preferences"

    assert_response :ok
    assert_equal "/settings/user_preferences", redirect_path_for("en")
    assert_equal "/hu/settings/user_preferences", redirect_path_for("hu")
  end

  test "the paths drop the locale prefix for the default locale" do
    sign_in!

    get "/hu/settings/user_preferences"

    assert_response :ok
    assert_equal "/settings/user_preferences", redirect_path_for("en")
    assert_equal "/hu/settings/user_preferences", redirect_path_for("hu")
  end

  private
  def redirect_path_for(code)
    data = JSON.parse(
      Nokogiri::HTML(response.body).
        at_css("[data-react-id='settings-language-preference-form']")['data-react-data']
    )

    data['languages'].find { |language| language['code'] == code }&.fetch('redirect_path')
  end
end
