# Serves the discovery documents MCP clients read to find out how to sign
# users in to /mcp: RFC 9728 protected resource metadata, pointing at our
# RFC 8414 authorization server metadata.
class OauthMetadataController < ActionController::API
  def protected_resource
    render json: {
      resource: "#{request.base_url}/mcp",
      authorization_servers: [request.base_url],
      scopes_supported: ["mcp"],
      bearer_methods_supported: ["header"]
    }
  end

  def authorization_server
    render json: {
      issuer: request.base_url,
      authorization_endpoint: oauth_authorization_url,
      token_endpoint: oauth_token_url,
      revocation_endpoint: oauth_revoke_url,
      scopes_supported: %w[mcp],
      response_types_supported: ["code"],
      grant_types_supported: %w[authorization_code refresh_token],
      token_endpoint_auth_methods_supported: %w[none client_secret_basic client_secret_post],
      code_challenge_methods_supported: ["S256"],
      client_id_metadata_document_supported: true
    }
  end
end
