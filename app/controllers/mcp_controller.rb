# Serves Exercism's Model Context Protocol (MCP) server, which lets
# AI agents such as Claude look things up on Exercism through tools.
#
# A fresh stateless server is built per request and answers with plain
# JSON, so no session or SSE state needs to live in the process. That
# keeps it working across our multiple Puma workers and servers.
#
# Every request needs an OAuth access token with the mcp scope. Requests
# without a valid one get a 401 pointing at our OAuth metadata, which is how
# MCP clients know to sign the user in. Expired tokens get the same 401, so
# the client refreshes them.
#
# This deliberately inherits from ActionController::API. ApplicationController's
# filters are built for browser pages, and its session-based current_user must
# never identify an MCP caller. Authentication here must only use Bearer tokens.
class MCPController < ActionController::API
  TOOLS = [
    GetProfileTool,
    GetCurrentUserTool
  ].freeze

  # Requests per user per minute, shared across all their MCP clients. This is
  # keyed on the user rather than the token because tokens are replaced on
  # every refresh. The website's Cloudflare rate limit excludes /mcp, because
  # claude.ai and ChatGPT call it for all their users from a few shared IPs.
  RATE_LIMIT = 60

  def handle
    return render_unauthorized unless current_user
    return render_rate_limited if rate_limited?

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
      tools: TOOLS,
      server_context: { user: current_user }
    )

    MCP::Server::Transports::StreamableHTTPTransport.new(
      server,
      stateless: true,
      enable_json_response: true,
      serve_subscriptions_listen: false,

      # DNS rebinding attacks target servers on localhost. This one is public
      # and only accepts Bearer tokens, so the check protects nothing.
      dns_rebinding_protection: false
    )
  end

  def render_unauthorized
    response.headers["WWW-Authenticate"] = [
      'Bearer error="invalid_token"',
      %(resource_metadata="#{OauthApplication.issuer}/.well-known/oauth-protected-resource/mcp"),
      'scope="mcp"'
    ].join(", ")
    head :unauthorized
  end

  def rate_limited?
    count = Rails.cache.increment("rate-limit:mcp:#{current_user.id}", 1, expires_in: 1.minute)
    count.to_i > RATE_LIMIT
  end

  def render_rate_limited
    response.headers["Retry-After"] = "60"
    head :too_many_requests
  end

  def current_user
    return @current_user if defined?(@current_user)

    token = Doorkeeper::OAuth::Token.authenticate(request, :from_bearer_authorization)
    valid = token&.accessible? && token.includes_scope?("mcp")
    @current_user = valid ? User.find_by(id: token.resource_owner_id) : nil
  end
end
