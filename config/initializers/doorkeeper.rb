# frozen_string_literal: true

Doorkeeper.configure do
  orm :active_record

  # Use Devise's current_user. If the user isn't signed in, bounce them to
  # the normal Exercism sign-in flow with a return-to back to /oauth/authorize.
  resource_owner_authenticator do
    current_user || begin
      store_location_for(:user, request.fullpath)
      redirect_to(new_user_session_url)
    end
  end

  # Restrict the Doorkeeper application admin UI to admins.
  admin_authenticator do
    current_user&.admin? || head(:forbidden)
  end

  # MCP clients such as Claude identify themselves with a Client ID Metadata
  # Document URL. OauthApplication turns those into applications on the fly.
  application_class 'OauthApplication'

  # Applications we create by hand (Jiki) are trusted first-party clients and
  # get no consent screen. MCP clients must always ask the user.
  skip_authorization do |_resource_owner, client|
    !client.application.mcp_client?
  end

  # Jiki exchanges its token for a single /api/oauth/userinfo call and then
  # discards it. MCP clients keep using theirs, so they get refresh tokens.
  # Doorkeeper revokes each refresh token when it's used, as OAuth 2.1
  # requires for public clients.
  use_refresh_token do |context|
    # Doorkeeper passes either the application or a client wrapping it.
    client = context.client
    application = client.is_a?(OauthApplication) ? client : client.application
    application.mcp_client?
  end
  access_token_expires_in 10.minutes
  authorization_code_expires_in 5.minutes

  # PKCE is required for all clients.
  force_pkce

  # Only support the Authorization Code flow.
  grant_flows %w[authorization_code]

  # profile is Jiki's identity info via userinfo. mcp is access to /mcp, and
  # is the only scope MCP clients are given.
  default_scopes :profile
  optional_scopes :mcp

  # Claude Code redirects to http://localhost:<port>/callback, so loopback
  # redirect URIs may use plain http.
  force_ssl_in_redirect_uri do |uri|
    !Doorkeeper::OAuth::Helpers::URIChecker.loopback_uri?(uri)
  end

  # The Authorization header is the only acceptable place for the token.
  access_token_methods :from_bearer_authorization

  # Reuse a valid token rather than minting a new one on each authorize.
  reuse_access_token

  base_controller 'ApplicationController'
end

# Native clients such as Claude Code pick a random port for their redirect, so
# RFC 8252 says the port is ignored when matching loopback redirect URIs.
# Doorkeeper only does that for loopback IPs. Claude Code uses localhost, so
# treat that as loopback too.
Doorkeeper::OAuth::Helpers::URIChecker.singleton_class.prepend(
  Module.new do
    def loopback_uri?(uri)
      uri.host == "localhost" || super
    end
  end
)

# RFC 9207: include our issuer as iss on authorization responses, so clients
# can check the code came from the server they started with. Doorkeeper
# doesn't support this. ChatGPT only uses its stable client_id with servers
# that do. Only MCP clients get it, so Jiki's responses are unchanged.
Doorkeeper::OAuth::CodeResponse.prepend(
  Module.new do
    def body
      body = super
      return body unless auth.try(:access_grant?) && pre_auth.client.application.mcp_client?

      body.merge(iss: OauthApplication.issuer)
    end
  end
)
