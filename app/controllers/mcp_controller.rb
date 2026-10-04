# Serves Exercism's Model Context Protocol (MCP) server, which lets
# AI agents such as Claude look things up on Exercism through tools.
#
# A fresh stateless server is built per request and answers with plain
# JSON, so no session or SSE state needs to live in the process. That
# keeps it working across our multiple Puma workers and servers.
#
# Everything here is currently public and anonymous. Authentication will
# arrive with the first tool that needs to know who the user is.
#
# This deliberately inherits from ActionController::API. ApplicationController's
# filters are built for browser pages, and its session-based current_user must
# never identify an MCP caller. Authentication here must only use Bearer tokens.
class MCPController < ActionController::API
  TOOLS = [
    GetProfileTool
  ].freeze

  def handle
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
      tools: TOOLS
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
end
