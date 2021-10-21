# This controller listens for Github organization webhook events,
# for which the "Organizations" event type must be enabled in GitHub.
# See https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#organization
module Webhooks
  class OrganizationUpdatesController < GithubBaseController
    def create
      process_member_update if member_added_or_removed?

      head :no_content
    end

    private
    def process_member_update
      ::Webhooks::ProcessOrganizationMemberUpdate.(
        # params[:action] does not work as it is populated by Rails with the action method name
        request.request_parameters[:action],
        params[:membership][:user][:login],
        params[:organization][:login]
      )
    end

    def member_added_or_removed?
      %w[member_added member_removed].include?(request.request_parameters[:action])
    end
  end
end
