# This controller listens for Github push webhook events,
# for which the "Pushes" event type must be enabled in GitHub.
# See https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#push
module Webhooks
  class PushUpdatesController < BaseController
    def create
      ::Webhooks::ProcessPushUpdate.(params[:ref], params[:repository][:name])

      head :no_content
    end
  end
end
