# This controller listens for Github push webhook events,
# for which the "Pushes" event type must be enabled in GitHub.
# See https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#push
module Webhooks
  class PushUpdatesController < GithubBaseController
    def create
      ::Webhooks::ProcessPushUpdate.(
        params[:ref],
        params[:repository][:owner][:login],
        params[:repository][:name],
        params[:pusher][:name],
        params[:commits],
        params[:created]
      )

      head :no_content
    end
  end
end
