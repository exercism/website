require_relative '../test_base'

class Payments::Paypal::RequestAccessTokenTest < Payments::TestBase
  test "gets access token" do
    freeze_time do
      access_token = SecureRandom.uuid
      expires_in = 90.seconds

      stub_request(:post, "https://api-m.sandbox.paypal.com/v1/oauth2/token").
        with(
          body: { "grant_type" => "client_credentials" },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
        ).
        to_return(status: 200, body: { access_token:, expires_in: }.to_json, headers: {})

      token = Payments::Paypal::RequestAccessToken.()

      assert_equal access_token, token
    end
  end
end
