require "test_helper"

class MCPControllerTest < ActionDispatch::IntegrationTest
  test "lists tools" do
    post_rpc "tools/list", token: create_token(create(:user), "mcp").token

    assert_response :ok
    tool_names = response.parsed_body.dig("result", "tools").map { |tool| tool["name"] }
    assert_equal %w[get_profile get_current_user], tool_names
  end

  test "calls get_profile" do
    user = create :user, handle: 'iHiD'
    create(:user_profile, user:)

    post_rpc "tools/call", { name: "get_profile", arguments: { handle: "iHiD" } }, token: create_token(user, "mcp").token

    assert_response :ok
    result = response.parsed_body["result"]
    refute result["isError"]
    assert_equal SerializeProfileSummary.(user).to_json, result.dig("content", 0, "text")
  end

  test "asks for sign-in without a token" do
    %w[initialize tools/list].each do |method|
      post_rpc method

      assert_response :unauthorized
      assert_equal 'Bearer error="invalid_token", ' \
        'resource_metadata="https://test.exercism.org/.well-known/oauth-protected-resource/mcp", scope="mcp"',
        response.headers["WWW-Authenticate"]
    end
  end

  test "ignores a signed-in browser session" do
    sign_in!

    post_rpc "tools/list"

    assert_response :unauthorized
  end

  test "calls get_current_user" do
    user = create :user, handle: 'iHiD'
    token = create_token(user, "mcp")

    post_rpc "tools/call", { name: "get_current_user", arguments: {} }, token: token.token

    assert_response :ok
    assert_equal "iHiD", JSON.parse(response.parsed_body.dig("result", "content", 0, "text"))["handle"]
  end

  test "rate limits each user across their tokens" do
    user = create :user
    first_token = create_token(user, "mcp").token
    second_token = create_token(user, "mcp").token

    MCPController::RATE_LIMIT.times { post_rpc "tools/list", token: first_token }
    assert_response :ok

    post_rpc "tools/list", token: second_token
    assert_response :too_many_requests
    assert_equal "60", response.headers["Retry-After"]

    post_rpc "tools/list", token: create_token(create(:user), "mcp").token
    assert_response :ok

    travel 61.seconds do
      post_rpc "tools/list", token: first_token
      assert_response :ok
    end
  end

  test "rejects a token without the mcp scope" do
    token = create_token(create(:user), "profile")

    post_rpc "tools/list", token: token.token

    assert_response :unauthorized
  end

  test "rejects an expired token" do
    token = create_token(create(:user), "mcp")

    travel 11.minutes do
      post_rpc "tools/list", token: token.token
    end

    assert_response :unauthorized
  end

  private
  def post_rpc(method, params = {}, token: nil)
    headers = {
      "Content-Type" => "application/json",
      "Accept" => "application/json, text/event-stream",
      "MCP-Protocol-Version" => "2025-06-18"
    }
    headers["Authorization"] = "Bearer #{token}" if token

    post mcp_path, params: { jsonrpc: "2.0", id: 1, method:, params: }.to_json, headers:
  end

  def create_token(user, scopes)
    application = OauthApplication.create!(name: "Test", redirect_uri: "https://example.com/callback")
    Doorkeeper::AccessToken.create!(application:, resource_owner_id: user.id, scopes:, expires_in: 10.minutes)
  end
end
