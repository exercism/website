require "test_helper"

class MCPControllerTest < ActionDispatch::IntegrationTest
  test "lists tools" do
    post_rpc "tools/list"

    assert_response :ok
    tool_names = response.parsed_body.dig("result", "tools").map { |tool| tool["name"] }
    assert_equal ["get_profile"], tool_names
  end

  test "calls get_profile" do
    user = create :user, handle: 'iHiD'
    create(:user_profile, user:)

    post_rpc "tools/call", { name: "get_profile", arguments: { handle: "iHiD" } }

    assert_response :ok
    result = response.parsed_body["result"]
    refute result["isError"]
    assert_equal SerializeProfileSummary.(user).to_json, result.dig("content", 0, "text")
  end

  test "works for a signed-in user" do
    sign_in!

    post_rpc "tools/list"

    assert_response :ok
  end

  private
  def post_rpc(method, params = {})
    post mcp_path,
      params: { jsonrpc: "2.0", id: 1, method:, params: }.to_json,
      headers: {
        "Content-Type" => "application/json",
        "Accept" => "application/json, text/event-stream",
        "MCP-Protocol-Version" => "2025-06-18"
      }
  end
end
