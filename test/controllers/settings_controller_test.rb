require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "user disconnects from discord" do
    user = create :user, discord_uid: 123
    assert user.discord_uid # Sanity

    sign_in!(user)
    delete disconnect_discord_settings_path

    assert_redirected_to integrations_settings_path
    assert_nil user.reload.discord_uid
  end
end
