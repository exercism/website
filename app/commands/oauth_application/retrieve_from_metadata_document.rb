# Finds or creates the OauthApplication for an MCP client's Client ID
# Metadata Document URL, refetching the document every few minutes so
# changes to the client's redirect URIs are picked up.
class OauthApplication::RetrieveFromMetadataDocument
  include Mandate

  # We only fetch documents from clients we trust. Sticking to known public
  # hosts also stops a client_id being used to make us request internal URLs.
  ALLOWED_HOSTS = %w[claude.ai chatgpt.com vscode.dev].freeze

  REFETCH_AFTER = 5.minutes
  MAX_DOCUMENT_SIZE = 5.kilobytes

  initialize_with :url

  def call
    return unless allowed_url?
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

  def allowed_url?
    uri = URI.parse(url)
    uri.scheme == "https" &&
      ALLOWED_HOSTS.include?(uri.host) &&
      uri.port == 443 &&
      uri.userinfo.nil? &&
      uri.fragment.nil? &&
      uri.path.present?
  rescue URI::InvalidURIError
    false
  end

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
