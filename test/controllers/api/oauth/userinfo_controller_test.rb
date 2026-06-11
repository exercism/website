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
      is_insider: false,
      is_bootcamp_member: false
    )
  end

  test "reports is_insider true for active insider" do
    user = create(:user)
    user.data.update!(insiders_status: :active)
    application = Doorkeeper::Application.create!(name: "Jiki",
      redirect_uri: "https://example.com/cb", scopes: "profile")
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: user.id,
      scopes: "profile", expires_in: 600)

    get api_oauth_userinfo_path,
      headers: { 'Authorization' => "Bearer #{token.token}" }, as: :json
    assert_response :ok
    assert response.parsed_body["is_insider"]
  end

  test "reports is_insider true for lifetime insider" do
    user = create(:user)
    user.data.update!(insiders_status: :active_lifetime)
    application = Doorkeeper::Application.create!(name: "Jiki",
      redirect_uri: "https://example.com/cb", scopes: "profile")
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: user.id,
      scopes: "profile", expires_in: 600)

    get api_oauth_userinfo_path,
      headers: { 'Authorization' => "Bearer #{token.token}" }, as: :json
    assert_response :ok
    assert response.parsed_body["is_insider"]
  end

  test "reports is_bootcamp_member for enrolled user" do
    user = create(:user)
    create(:user_bootcamp_data, user:, enrolled_on_part_1: true)
    application = Doorkeeper::Application.create!(name: "Jiki",
      redirect_uri: "https://example.com/cb", scopes: "profile")
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: user.id,
      scopes: "profile", expires_in: 600)

    get api_oauth_userinfo_path,
      headers: { 'Authorization' => "Bearer #{token.token}" }, as: :json
    assert_response :ok
    assert response.parsed_body["is_bootcamp_member"]
  end

  test "reports is_bootcamp_member for bootcamp mentor" do
    user = create(:user, bootcamp_mentor: true)
    application = Doorkeeper::Application.create!(name: "Jiki",
      redirect_uri: "https://example.com/cb", scopes: "profile")
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: user.id,
      scopes: "profile", expires_in: 600)

    get api_oauth_userinfo_path,
      headers: { 'Authorization' => "Bearer #{token.token}" }, as: :json
    assert_response :ok
    assert response.parsed_body["is_bootcamp_member"]
  end
end
