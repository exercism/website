require 'test_helper'

module Webhooks
  class BaseTestCase < ActionDispatch::IntegrationTest
    def headers(payload, event: 'push')
      @headers = {
        'HTTP_X_GITHUB_DELIVERY' => SecureRandom.uuid,
        'HTTP_X_HUB_SIGNATURE_256' => signature(payload),
        'HTTP_X_GITHUB_EVENT' => event
      }
    end

    def signature(payload)
      digest = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        Exercism.secrets.github_webhooks_secret, payload.to_json
      )
      "sha256=#{digest}"
    end
  end
end
