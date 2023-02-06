# This controller listens for Github membership webhook events,
# for which the "Memberships" event type must be enabled in GitHub.
# See https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads#membership
module Webhooks
  class MembershipUpdatesController < GithubBaseController
    def create
      ::Webhooks::ProcessMembershipUpdate.(
        # params[:action] does not work as it is populated by Rails with the action method name
        request.request_parameters[:action],
        params[:member][:id],
        params[:team][:name],
        params[:organization][:login]
      )

      head :no_content
    end
  end
end
