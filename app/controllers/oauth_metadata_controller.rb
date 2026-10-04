# Serves the discovery documents MCP clients read to find out how to sign
# users in to /mcp: RFC 9728 protected resource metadata, pointing at our
# RFC 8414 authorization server metadata.
class OauthMetadataController < ActionController::API
  def protected_resource
    render json: {
      resource: "#{OauthApplication.issuer}/mcp",
      authorization_servers: [OauthApplication.issuer],
      scopes_supported: ["mcp"],
      bearer_methods_supported: ["header"]
    }
  end

  def authorization_server
    render json: {
      issuer: OauthApplication.issuer,
      authorization_endpoint: "#{OauthApplication.issuer}#{oauth_authorization_path}",
      token_endpoint: "#{OauthApplication.issuer}#{oauth_token_path}",
      revocation_endpoint: "#{OauthApplication.issuer}#{oauth_revoke_path}",
      scopes_supported: %w[mcp],
      response_types_supported: ["code"],
      grant_types_supported: %w[authorization_code refresh_token],
      token_endpoint_auth_methods_supported: %w[none client_secret_basic client_secret_post],
      code_challenge_methods_supported: ["S256"],
      client_id_metadata_document_supported: true,
      authorization_response_iss_parameter_supported: true
    }
  end
end
