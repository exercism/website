class Payments::Paypal::RequestAccessToken
  include Mandate

  CACHE_KEY = :paypal_access_token

  def call
    access_token = Rails.cache.read(CACHE_KEY)
    return access_token if access_token.present?

    token = request_token!
    token[:access_token].tap do |new_access_token|
      expires_in = token[:expires_in].to_i - EXPIRY_TIME_OFFSET
      Rails.cache.write(CACHE_KEY, new_access_token, expires_in:)
    end
  end

  private
  def request_token!
    response = RestClient.post(url, payload, headers)
    JSON.parse(response.body, symbolize_names: true)
  end

  def url = "#{Exercism.config.paypal_api_url}/v1/oauth2/token"
  def payload = "grant_type=client_credentials"

  def headers
    {
      authorization: "Basic #{basic_credentials}",
      content_type: "application/x-www-form-urlencoded"
    }
  end

  def basic_credentials = Base64.strict_encode64("#{Exercism.secrets.paypal_client_id}:#{Exercism.secrets.paypal_client_secret}")

  EXPIRY_TIME_OFFSET = 10.seconds
  private_constant :EXPIRY_TIME_OFFSET
end
