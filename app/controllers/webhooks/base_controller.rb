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
    skip_after_action :set_body_class_header
    skip_around_action :mark_notifications_as_read!
    skip_after_action :updated_last_visited_on!

    layout false

    def payload_body
      request.body.rewind
      request.body.read
    end
  end
end
