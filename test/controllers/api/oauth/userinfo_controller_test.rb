require_relative '../base_test_case'

class API::Oauth::UserinfoControllerTest < API::BaseTestCase
  test "returns 401 without a token" do
    get api_oauth_userinfo_path, as: :json
    assert_response :unauthorized
  end

  test "returns 401 with a bad token" do
    get api_oauth_userinfo_path,
      headers: { 'Authorization' => "Bearer not-a-real-token" }, as: :json
    assert_response :unauthorized
  end

  test "returns the userinfo payload for a valid token" do
    user = create(:user, handle: "alice", name: "Alice", email: "alice@example.com",
      avatar_url: "https://example.com/a.png")
    user.confirm

    application = Doorkeeper::Application.create!(name: "Jiki",
      redirect_uri: "https://example.com/cb", scopes: "profile")
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: user.id,
      scopes: "profile", expires_in: 600)

    get api_oauth_userinfo_path,
      headers: { 'Authorization' => "Bearer #{token.token}" }, as: :json
    assert_response :ok

    assert_json_response(
      id: user.id,
      handle: "alice",
      name: "Alice",
      email: "alice@example.com",
      avatar_url: "https://test.exercism.org#{user.avatar_url}",
      membership_status: "normal"
    )
  end

  test "reports insider membership" do
    user = create(:user)
    user.data.update!(insiders_status: :active)
    application = Doorkeeper::Application.create!(name: "Jiki",
      redirect_uri: "https://example.com/cb", scopes: "profile")
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: user.id,
      scopes: "profile", expires_in: 600)

    get api_oauth_userinfo_path,
      headers: { 'Authorization' => "Bearer #{token.token}" }, as: :json
    assert_response :ok
    assert_equal "insider", response.parsed_body["membership_status"]
  end

  test "reports lifetime_insider membership" do
    user = create(:user)
    user.data.update!(insiders_status: :active_lifetime)
    application = Doorkeeper::Application.create!(name: "Jiki",
      redirect_uri: "https://example.com/cb", scopes: "profile")
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: user.id,
      scopes: "profile", expires_in: 600)

    get api_oauth_userinfo_path,
      headers: { 'Authorization' => "Bearer #{token.token}" }, as: :json
    assert_response :ok
    assert_equal "lifetime_insider", response.parsed_body["membership_status"]
  end
end
