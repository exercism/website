require_relative './base_test_case'

class API::IntegrationsControllerTest < API::BaseTestCase
  test "user disconnects from discord" do
    user = create :user, discord_uid: 123
    assert user.discord_uid # Sanity

    setup_user(user)
    delete disconnect_discord_api_integrations_path

    assert_nil user.reload.discord_uid
  end
end
