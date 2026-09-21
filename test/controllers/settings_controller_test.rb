require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "language field is rendered inside the profile form" do
    user = create :user
    sign_in!(user)

    get settings_path

    assert_response :ok
    assert_select "div[data-react-id=?]", "settings-profile-form" do |elements|
      data = JSON.parse(elements.first["data-react-data"])
      assert_equal I18n.default_locale.to_s, data["default_locale"]
      english = data["languages"].find { |language| language["code"] == "en" }
      assert_equal "English", english["native"]
      assert_equal "English", english["english"]
      assert_match %r{/assets/flags/3x2/gb.*\.svg}, english["flag_url"]
      assert_includes data["coming_soon_languages"].map { |language| language["code"] }, "fr"
      assert_equal Exercism::Routes.api_settings_language_url, data.dig("links", "update_language")
    end

    assert_select "div[data-react-id=?]", "settings-language-form", count: 0
    assert_select "section.language-section", count: 0
  end

  test "user disconnects from discord" do
    user = create :user, discord_uid: 123
    assert user.discord_uid # Sanity

    sign_in!(user)
    delete disconnect_discord_settings_path

    assert_redirected_to integrations_settings_path
    assert_nil user.reload.discord_uid
  end

  test "reset_account resets in the background" do
    user = create :user, bio: "Some bio"

    sign_in!(user)
    perform_enqueued_jobs do
      patch reset_account_settings_path, params: { handle: user.handle }, as: :json
    end

    assert_response :ok
    assert_nil user.reload.bio
  end

  test "reset_account does nothing with the wrong handle" do
    user = create :user, bio: "Some bio"

    sign_in!(user)
    perform_enqueued_jobs do
      patch reset_account_settings_path, params: { handle: "someone-else" }, as: :json
    end

    assert_response :ok
    assert_equal "Some bio", user.reload.bio
  end
end
