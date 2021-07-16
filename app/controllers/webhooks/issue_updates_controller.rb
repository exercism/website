# This controller listens for Github pull request webhook events,
# for which the "Issues" event type must be enabled in GitHub.
# See https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#issues
module Webhooks
  class IssueUpdatesController < GithubBaseController
    def create
      ::Webhooks::ProcessIssueUpdate.(
        # params[:action] does not work as it is populated by Rails with the action method name
        action: request.request_parameters[:action],
        node_id: params[:issue][:node_id],
        number: params[:issue][:number],
        title: params[:issue][:title],
        state: params[:issue][:state],
        html_url: params[:issue][:html_url],
        repo: params[:repository][:full_name],
        labels: params[:issue][:labels].map { |label| label[:name] },
        opened_at: params[:issue][:created_at].present? ? Time.parse(params[:issue][:created_at]).utc : nil,
        opened_by_username: params[:issue][:user][:login]
      )

      head :no_content
    end
  end
end
