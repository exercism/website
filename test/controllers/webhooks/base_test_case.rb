require 'test_helper'

module Webhooks
  class BaseTestCase < ActionDispatch::IntegrationTest
    def headers(payload)
      @headers = {
        'HTTP_X_GITHUB_DELIVERY' => SecureRandom.uuid,
        'HTTP_X_HUB_SIGNATURE_256' => signature(payload)
      }
    end

    def signature(payload)
      'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),
        Exercism.secrets.github_webhooks_secret, payload.to_json)
    end
  end
end
