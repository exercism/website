require 'test_helper'

module Webhooks
  class BaseTestCase < ActionDispatch::IntegrationTest
    def headers(payload)
      delivery = SecureRandom.uuid
      signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),
        Exercism.secrets.github_webhooks_secret, payload.to_json)

      @headers = {
        'HTTP_X_GITHUB_DELIVERY' => delivery,
        'HTTP_X_HUB_SIGNATURE_256' => signature
      }
    end
  end
end
