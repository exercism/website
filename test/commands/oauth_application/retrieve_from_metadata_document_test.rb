require 'test_helper'

class OauthApplication::RetrieveFromMetadataDocumentTest < ActiveSupport::TestCase
  URL = "https://claude.ai/oauth/mcp-oauth-client-metadata".freeze

  test "creates an application from the document" do
    stub_document

    app = OauthApplication::RetrieveFromMetadataDocument.(URL)

    assert app.persisted?
    assert_equal URL, app.uid
    assert_equal "Claude", app.name
    assert_equal "https://claude.ai/api/mcp/auth_callback", app.redirect_uri
    assert_equal "mcp", app.scopes.to_s
    refute app.confidential?
    assert app.mcp_client?
  end

  test "reuses the application without refetching for a few minutes" do
    stub_document
    app = OauthApplication::RetrieveFromMetadataDocument.(URL)

    travel 4.minutes do
      assert_equal app, OauthApplication::RetrieveFromMetadataDocument.(URL)
    end

    assert_requested :get, URL, times: 1
  end

  test "refetches the document after a few minutes" do
    stub_document
    app = OauthApplication::RetrieveFromMetadataDocument.(URL)

    stub_document(redirect_uris: ["https://claude.ai/new_callback"])
    travel 6.minutes do
      assert_equal "https://claude.ai/new_callback", OauthApplication::RetrieveFromMetadataDocument.(URL).redirect_uri
    end
    assert_equal 1, OauthApplication.where(uid: app.uid).count
  end

  test "keeps the existing application if refetching fails" do
    stub_document
    app = OauthApplication::RetrieveFromMetadataDocument.(URL)

    stub_request(:get, URL).to_return(status: 500)
    travel 6.minutes do
      assert_equal app, OauthApplication::RetrieveFromMetadataDocument.(URL)
    end
  end

  test "rejects hosts that aren't allowed" do
    url = "https://evil.example.com/client.json"

    assert_nil OauthApplication::RetrieveFromMetadataDocument.(url)
    assert_not_requested :get, url
  end

  test "rejects non-default ports and userinfo" do
    assert_nil OauthApplication::RetrieveFromMetadataDocument.("https://claude.ai:8443/client.json")
    assert_nil OauthApplication::RetrieveFromMetadataDocument.("https://user@claude.ai/client.json")
  end

  test "rejects a document whose client_id doesn't match the URL" do
    stub_document(client_id: "https://claude.ai/something-else")

    assert_nil OauthApplication::RetrieveFromMetadataDocument.(URL)
  end

  test "rejects confidential clients" do
    stub_document(token_endpoint_auth_method: "client_secret_basic")

    assert_nil OauthApplication::RetrieveFromMetadataDocument.(URL)
  end

  test "rejects redirects" do
    stub_request(:get, URL).to_return(status: 302, headers: { "Location" => "https://claude.ai/other" })

    assert_nil OauthApplication::RetrieveFromMetadataDocument.(URL)
  end

  test "rejects oversized documents" do
    stub_document(client_name: "x" * 6.kilobytes)

    assert_nil OauthApplication::RetrieveFromMetadataDocument.(URL)
  end

  test "rejects invalid JSON" do
    stub_request(:get, URL).to_return(status: 200, body: "not json")

    assert_nil OauthApplication::RetrieveFromMetadataDocument.(URL)
  end

  private
  def stub_document(**overrides)
    document = {
      client_id: URL,
      client_name: "Claude",
      redirect_uris: ["https://claude.ai/api/mcp/auth_callback"],
      token_endpoint_auth_method: "none"
    }.merge(overrides)

    stub_request(:get, URL).to_return(status: 200, body: document.to_json, headers: { "Content-Type" => "application/json" })
  end
end
