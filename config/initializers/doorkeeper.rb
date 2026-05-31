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

  # Jiki is a trusted first-party client — no consent screen.
  skip_authorization do
    true
  end

  # Identity-only OAuth: the access token is exchanged for a single
  # /api/oauth/userinfo call and then discarded by the client. Keep it
  # short-lived and don't issue refresh tokens.
  access_token_expires_in 10.minutes
  authorization_code_expires_in 5.minutes

  # PKCE is required for all clients.
  force_pkce

  # Only support the Authorization Code flow.
  grant_flows %w[authorization_code]

  # We use one implicit scope: identity info via userinfo.
  default_scopes :profile
  optional_scopes

  # The Authorization header is the only acceptable place for the token
  # on the userinfo endpoint.
  access_token_methods :from_bearer_authorization

  # Reuse a valid token rather than minting a new one on each authorize.
  reuse_access_token

  base_controller 'ApplicationController'
end
