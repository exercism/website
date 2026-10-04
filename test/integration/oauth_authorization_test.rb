require "test_helper"

class OauthAuthorizationTest < ActionDispatch::IntegrationTest
  CLAUDE_CODE = "https://claude.ai/oauth/claude-code-client-metadata".freeze

  test "first-party applications skip the consent screen" do
    sign_in!
    app = OauthApplication.create!(name: "Jiki", redirect_uri: "https://jiki.io/callback")

    get oauth_authorization_path(authorize_params(app.uid, "https://jiki.io/callback"))

    assert_response :redirect
    assert response.location.start_with?("https://jiki.io/callback?code=")
  end

  test "MCP clients see a consent screen showing their host" do
    sign_in!
    stub_claude_code

    get oauth_authorization_path(authorize_params(CLAUDE_CODE, "http://localhost:54321/callback", scope: "mcp"))

    assert_response :ok
    assert_includes response.body, "claude.ai"
    assert_includes response.body, "localhost"
  end

  test "MCP clients can't request the profile scope" do
    sign_in!
    stub_claude_code

    get oauth_authorization_path(authorize_params(CLAUDE_CODE, "http://localhost:54321/callback", scope: "profile"))

    refute_includes response.body, "Authorize"
  end

  test "MCP clients get a refresh token" do
    user = create :user
    sign_in!(user)
    stub_claude_code
    verifier = SecureRandom.hex(32)
    redirect_uri = "http://127.0.0.1:54321/callback"

    post oauth_authorization_path, params: authorize_params(CLAUDE_CODE, redirect_uri, scope: "mcp", verifier:)
    code = Rack::Utils.parse_query(URI(response.location).query)["code"]

    post oauth_token_path, params: {
      grant_type: "authorization_code", client_id: CLAUDE_CODE, code:, redirect_uri:, code_verifier: verifier
    }

    assert_response :ok
    assert response.parsed_body["refresh_token"].present?
    assert_equal "mcp", response.parsed_body["scope"]
  end

  private
  def authorize_params(client_id, redirect_uri, scope: nil, verifier: "x" * 43)
    {
      client_id:,
      redirect_uri:,
      response_type: "code",
      scope:,
      code_challenge: Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false),
      code_challenge_method: "S256"
    }.compact
  end

  def stub_claude_code
    document = {
      client_id: CLAUDE_CODE,
      client_name: "Claude Code",
      redirect_uris: ["http://localhost/callback", "http://127.0.0.1/callback"],
      token_endpoint_auth_method: "none"
    }
    stub_request(:get, CLAUDE_CODE).to_return(status: 200, body: document.to_json)
  end
end
