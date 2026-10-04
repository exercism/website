# Serves Exercism's Model Context Protocol (MCP) server, which lets
# AI agents such as Claude look things up on Exercism through tools.
#
# A fresh stateless server is built per request and answers with plain
# JSON, so no session or SSE state needs to live in the process. That
# keeps it working across our multiple Puma workers and servers.
#
# Public tools work without signing in. Calling a user tool without a valid
# token gets a 401 pointing at our OAuth metadata, which is how MCP clients
# know to sign the user in. The client then retries with an OAuth access
# token carrying the mcp scope.
#
# This deliberately inherits from ActionController::API. ApplicationController's
# filters are built for browser pages, and its session-based current_user must
# never identify an MCP caller. Authentication here must only use Bearer tokens.
class MCPController < ActionController::API
  PUBLIC_TOOLS = [
    GetProfileTool
  ].freeze

  USER_TOOLS = [
    GetCurrentUserTool
  ].freeze

  def handle
    # Invalid and expired tokens must get a 401 so the client refreshes them.
    return render_unauthorized if bearer_token? && current_user.nil?
    return render_unauthorized if current_user.nil? && calls_user_tool?

    status, headers, body = transport.handle_request(request)

    self.status = status
    headers.each { |key, value| response.headers[key] = value }
    self.response_body = body
  end

  private
  def transport
    server = MCP::Server.new(
      name: "exercism",
      title: "Exercism",
      version: "1.0.0",
      website_url: "https://exercism.org",
      tools: PUBLIC_TOOLS + USER_TOOLS,
      server_context: { user: current_user }
    )

    MCP::Server::Transports::StreamableHTTPTransport.new(
      server,
      stateless: true,
      enable_json_response: true,
      serve_subscriptions_listen: false,

      # DNS rebinding attacks target servers on localhost. This one is public
      # and can't read the user's session, so the check protects nothing.
      dns_rebinding_protection: false
    )
  end

  def render_unauthorized
    response.headers["WWW-Authenticate"] = [
      'Bearer error="invalid_token"',
      %(resource_metadata="#{request.base_url}/.well-known/oauth-protected-resource/mcp"),
      'scope="mcp"'
    ].join(", ")
    head :unauthorized
  end

  def bearer_token? = request.authorization.to_s.start_with?("Bearer ")

  def current_user
    return @current_user if defined?(@current_user)

    token = Doorkeeper::OAuth::Token.authenticate(request, :from_bearer_authorization)
    valid = token&.accessible? && token.includes_scope?("mcp")
    @current_user = valid ? User.find_by(id: token.resource_owner_id) : nil
  end

  def calls_user_tool?
    user_tool_names = USER_TOOLS.map(&:name_value)

    Array.wrap(JSON.parse(request.raw_post)).any? do |message|
      message.is_a?(Hash) &&
        message["method"] == "tools/call" &&
        user_tool_names.include?(message.dig("params", "name"))
    end
  rescue JSON::ParserError
    false
  end
end
