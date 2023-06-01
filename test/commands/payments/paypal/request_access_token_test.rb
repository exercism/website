require_relative '../test_base'

class Payments::Paypal::RequestAccessTokenTest < Payments::TestBase
  def setup = Rails.cache.clear(Payments::Paypal::RequestAccessToken::CACHE_KEY)

  test "gets access token" do
    freeze_time do
      access_token = SecureRandom.uuid
      expires_in = 90.seconds

      stub_request(:post, "https://api-m.sandbox.paypal.com/v1/oauth2/token").
        with(
          body: { "grant_type" => "client_credentials" },
          headers: {
            'Authorization' => 'Basic QVc5RHFSck1xQlhmS0F0OGphcXc1dDMwVVJVOGhpZ3NrYnhGVTFacHp4ZVJFYXppMmZKZnpNaTRyV2RuMVc2cC10YWk1UVlMdlluMUx6TWs6RUpfak95ekl0ZU1meXQ0VlBoNTN2dGg1RlpHNFQ1MEg1SXhTaUtTTFllenlJOXZPdmZsVG5lZ3dvVzhmV2owOEh3cnNiSzAyc1ViaEhFMi0=', # rubocop:disable Layout/LineLength
            'Content-Type' => 'application/x-www-form-urlencoded'
          }
        ).
        to_return(status: 200, body: { access_token:, expires_in: }.to_json, headers: {})

      token = Payments::Paypal::RequestAccessToken.()

      assert_equal access_token, token
    end
  end

  test "caches access token until expiry time" do
    freeze_time do
      access_token = SecureRandom.uuid
      expires_in = 90.seconds

      stub_request(:post, "https://api-m.sandbox.paypal.com/v1/oauth2/token").
        with(
          body: { "grant_type" => "client_credentials" },
          headers: {
            'Authorization' => 'Basic QVc5RHFSck1xQlhmS0F0OGphcXc1dDMwVVJVOGhpZ3NrYnhGVTFacHp4ZVJFYXppMmZKZnpNaTRyV2RuMVc2cC10YWk1UVlMdlluMUx6TWs6RUpfak95ekl0ZU1meXQ0VlBoNTN2dGg1RlpHNFQ1MEg1SXhTaUtTTFllenlJOXZPdmZsVG5lZ3dvVzhmV2owOEh3cnNiSzAyc1ViaEhFMi0=', # rubocop:disable Layout/LineLength
            'Content-Type' => 'application/x-www-form-urlencoded'
          }
        ).
        to_return(status: 200, body: { access_token:, expires_in: }.to_json, headers: {})

      Payments::Paypal::RequestAccessToken.()

      new_access_token = SecureRandom.uuid
      stub_request(:post, "https://api-m.sandbox.paypal.com/v1/oauth2/token").
        with(
          body: { "grant_type" => "client_credentials" },
          headers: {
            'Authorization' => 'Basic QVc5RHFSck1xQlhmS0F0OGphcXc1dDMwVVJVOGhpZ3NrYnhGVTFacHp4ZVJFYXppMmZKZnpNaTRyV2RuMVc2cC10YWk1UVlMdlluMUx6TWs6RUpfak95ekl0ZU1meXQ0VlBoNTN2dGg1RlpHNFQ1MEg1SXhTaUtTTFllenlJOXZPdmZsVG5lZ3dvVzhmV2owOEh3cnNiSzAyc1ViaEhFMi0=', # rubocop:disable Layout/LineLength
            'Content-Type' => 'application/x-www-form-urlencoded'
          }
        ).
        to_return(status: 200, body: { access_token: new_access_token, expires_in: }.to_json, headers: {})

      assert_equal access_token, Payments::Paypal::RequestAccessToken.()

      travel_to Time.current + expires_in
      assert_equal new_access_token, Payments::Paypal::RequestAccessToken.()

      assert_equal new_access_token, Payments::Paypal::RequestAccessToken.()
    end
  end
end
