require "test_helper"

class OauthMetadataControllerTest < ActionDispatch::IntegrationTest
  test "protected resource metadata" do
    %w[/.well-known/oauth-protected-resource /.well-known/oauth-protected-resource/mcp].each do |path|
      get path

      assert_response :ok
      assert_equal "https://test.exercism.org/mcp", response.parsed_body["resource"]
      assert_equal ["https://test.exercism.org"], response.parsed_body["authorization_servers"]
      assert_equal ["mcp"], response.parsed_body["scopes_supported"]
    end
  end

  test "authorization server metadata" do
    get "/.well-known/oauth-authorization-server"

    assert_response :ok
    metadata = response.parsed_body
    assert_equal "https://test.exercism.org", metadata["issuer"]
    assert_equal "https://test.exercism.org/oauth/authorize", metadata["authorization_endpoint"]
    assert_equal "https://test.exercism.org/oauth/token", metadata["token_endpoint"]
    assert metadata["client_id_metadata_document_supported"]
    assert_includes metadata["token_endpoint_auth_methods_supported"], "none"
    assert_equal ["S256"], metadata["code_challenge_methods_supported"]
    assert metadata["authorization_response_iss_parameter_supported"]
  end
end
