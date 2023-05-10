require "test_helper"

class Webhooks::Paypal::RequestAccessTokenTest < ActiveSupport::TestCase
  test "returns access token" do
    access_token = SecureRandom.uuid
    stub_request(:post, "https://api-m.sandbox.paypal.com/v1/oauth2/token").
      with(body: { "grant_type" => "client_credentials" }).
      to_return(status: 200, body: { access_token: }.to_json, headers: { 'Content-Type' => 'application/json' })

    requested_access_token = Webhooks::Paypal::RequestAccessToken.()
    assert_equal access_token, requested_access_token
  end

  test "raises when response is not success" do
    stub_request(:post, "https://api-m.sandbox.paypal.com/v1/oauth2/token").
      with(body: { "grant_type" => "client_credentials" }).
      to_return(status: 401, body: "", headers: {})

    assert_raises Webhooks::Paypal::RequestAccessToken::RequestAccessTokenError do
      Webhooks::Paypal::RequestAccessToken.()
    end
  end

  test "raises when response JSON is not valid" do
    stub_request(:post, "https://api-m.sandbox.paypal.com/v1/oauth2/token").
      with(body: { "grant_type" => "client_credentials" }).
      to_return(status: 200, body: '{ "access_tok"', headers: { 'Content-Type' => 'application/json' })

    assert_raises Webhooks::Paypal::RequestAccessToken::RequestAccessTokenError do
      Webhooks::Paypal::RequestAccessToken.()
    end
  end
end
