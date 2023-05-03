require 'uri'
require 'net/http'

class Webhooks::Paypal::RequestAccessToken
  class RequestAccessTokenError < RuntimeError; end

  include Mandate

  def call
    response = http.request(request)

    raise RequestAccessTokenError unless response.is_a?(Net::HTTPSuccess)

    response_body = JSON.parse(response.body, symbolize_names: true)
    response_body[:access_token]
  rescue StandardError
    raise RequestAccessTokenError
  end

  private
  memoize
  def http
    Net::HTTP.new(OAUTH2_TOKEN_URI.host, OAUTH2_TOKEN_URI.port).tap do |http|
      http.use_ssl = true
    end
  end

  def request
    Net::HTTP::Post.new(OAUTH2_TOKEN_URI.request_uri).tap do |request|
      request.basic_auth(Exercism.secrets.paypal_client_id, Exercism.secrets.paypal_client_secret)
      request.set_content_type('application/x-www-form-urlencoded')
      request.set_form_data({ 'grant_type' => 'client_credentials' })
    end
  end

  OAUTH2_TOKEN_URI = URI('https://api-m.sandbox.paypal.com/v1/oauth2/token').freeze
  private_constant :OAUTH2_TOKEN_URI
end
