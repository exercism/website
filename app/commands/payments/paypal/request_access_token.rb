class Payments::Paypal::RequestAccessToken
  include Mandate

  def call
    token = request_token!
    token[:access_token]
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
end
