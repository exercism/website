# Finds or creates the OauthApplication for an MCP client's Client ID
# Metadata Document URL, refetching the document every few minutes so
# changes to the client's redirect URIs are picked up.
class OauthApplication::RetrieveFromMetadataDocument
  include Mandate

  # The MCP clients we accept, by the exact URL of their metadata document.
  # Any other client_id is rejected without a fetch, so nobody can make us
  # request arbitrary or internal URLs, and each document is fetched at most
  # once every REFETCH_AFTER however many requests arrive.
  #
  # ChatGPT (https://chatgpt.com/oauth/client.json) isn't here because its
  # document declares private_key_jwt, which we don't support yet.
  ALLOWED_CLIENT_IDS = %w[
    https://claude.ai/oauth/mcp-oauth-client-metadata
    https://claude.ai/oauth/claude-code-client-metadata
    https://vscode.dev/oauth/client-metadata.json
    https://insiders.vscode.dev/oauth/client-metadata.json
    https://github.com/copilot/cli/client-metadata.json
    https://zed.dev/oauth/client-metadata.json
    https://goose-docs.ai/oauth/client-metadata.json
  ].freeze

  REFETCH_AFTER = 5.minutes
  MAX_DOCUMENT_SIZE = 5.kilobytes

  initialize_with :url

  def call
    return unless ALLOWED_CLIENT_IDS.include?(url)
    return application if application && application.updated_at > REFETCH_AFTER.ago

    # If the document can't be fetched, keep using what we had.
    return application unless document

    save_application!
  end

  private
  def save_application!
    app = application || OauthApplication.new(
      uid: url,
      secret: SecureRandom.hex(32),
      confidential: false,
      scopes: "mcp"
    )
    app.name = document[:client_name]
    app.redirect_uri = document[:redirect_uris].join("\n")
    app.updated_at = Time.current
    app.save!
    app
  rescue ActiveRecord::RecordNotUnique
    OauthApplication.find_by(uid: url)
  end

  memoize
  def application = OauthApplication.find_by(uid: url)

  memoize
  def document
    response = RestClient::Request.execute(method: :get, url:, timeout: 5, max_redirects: 0)
    return unless response.code == 200
    return if response.body.bytesize > MAX_DOCUMENT_SIZE

    doc = JSON.parse(response.body, symbolize_names: true)
    return unless doc.is_a?(Hash)
    return unless doc[:client_id] == url
    return unless doc[:client_name].is_a?(String) && doc[:client_name].present?
    return unless doc[:redirect_uris].is_a?(Array) && doc[:redirect_uris].present?
    return unless doc[:redirect_uris].all?(String)

    # We only support public clients, which authenticate with PKCE alone.
    return unless doc[:token_endpoint_auth_method] == "none"

    doc
  rescue RestClient::Exception, JSON::ParserError, SocketError, SystemCallError, OpenSSL::SSL::SSLError
    nil
  end
end
