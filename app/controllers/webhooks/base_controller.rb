# This is the base controller of Exercism's webhooks.
#
# It is intended to only be called from GitHub webhooks
# and should not be called by any other source

module Webhooks
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    before_action :verify_github_webhook!

    layout false

    private
    def verify_github_webhook!
      return if signature_valid?

      render json: {
        error: {
          type: :invalid_webhook_signature,
          message: "The auth token provided is invalid. Delivery: #{github_delivery}"
        }
      }, status: :forbidden
    end

    def signature_valid?
      signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), github_webhooks_secret, payload_body)
      Rack::Utils.secure_compare(signature, github_signature)
    end

    def payload_body
      request.body.rewind
      request.body.read
    end

    def github_webhooks_secret
      Exercism.secrets.github_webhooks_secret
    end

    def github_signature
      request.headers['HTTP_X_HUB_SIGNATURE_256']
    end

    def github_delivery
      request.headers['HTTP_X_GITHUB_DELIVERY']
    end
  end
end
