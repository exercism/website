require "test_helper"

class User::GithubSolutionSyncer::GithubAppTest < ActiveSupport::TestCase
  test "generates a valid JWT" do
    jwt = User::GithubSolutionSyncer::GithubApp.generate_jwt
    assert jwt.is_a?(String)

    decoded = JWT.decode(jwt, nil, false) # don't verify signature
    payload = decoded.first

    assert payload["iss"].present?
    assert payload["iat"].is_a?(Integer)
    assert payload["exp"].is_a?(Integer)
    assert payload["exp"] > payload["iat"]
  end

  test "calls GitHub and returns token on generate_installation_token!" do
    jwt = "fake.jwt.token"
    expected_token = "github-installation-token"
    installation_id = 123_456

    # Stub only the HTTP call, not generate_jwt
    User::GithubSolutionSyncer::GithubApp.expects(:generate_jwt).with(jwt) do
      stub_request(:post, "https://api.github.com/app/installations/#{installation_id}/access_tokens").
        to_return(status: 200, body: { token: expected_token }.to_json, headers: { "Content-Type" => "application/json" })
    end

    token = User::GithubSolutionSyncer::GithubApp.generate_installation_token!(installation_id)
    assert_equal expected_token, token
  end
end
