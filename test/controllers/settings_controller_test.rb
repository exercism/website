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
