# This is the base controller of Exercism's webhooks.
#
# It is intended to only be called from webhooks
# and should not be called by any other source.
#
# It is inherited by GitHubBaseController and StripeBaseController

module Webhooks
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    layout false

    def payload_body
      request.body.rewind
      request.body.read
    end
  end
end
