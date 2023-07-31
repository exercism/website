# This controller listens for Github sponsors webhook events,
# See https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#issues
module Webhooks
  class GithubSponsorsController < GithubBaseController
    def create
      ProcessGithubSponsorUpdateJob.perform_later(
        # params[:action] does not work as it is populated by Rails with the action method name
        request.request_parameters[:action],
        params[:sponsorship][:sponsor][:login],
        params[:sponsorship][:node_id],
        params[:sponsorship][:tier][:is_one_time],
        params[:sponsorship][:tier][:monthly_price_in_cents]
      )

      head :no_content
    end
  end
end
