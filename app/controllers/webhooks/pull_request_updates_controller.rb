module Webhooks
  class PullRequestUpdatesController < BaseController
    def create
      ::Webhooks::ProcessPullRequestUpdate.(
        # params[:action] does not work as it is populated by Rails with the action method name
        action: request.request_parameters[:action],
        author: params[:pull_request][:user][:login],
        url: params[:pull_request][:url],
        html_url: params[:pull_request][:html_url],
        labels: params[:pull_request][:labels].map { |label| label[:name] },
        state: params[:pull_request][:state],
        pr_node_id: params[:pull_request][:node_id],
        pr_number: params[:pull_request][:number],
        repo: params[:repository][:full_name],
        merged: params[:pull_request][:merged],
        merged_by: params[:pull_request][:merged_by].present? ? params[:pull_request][:merged_by][:login] : nil
      )

      head :no_content
    end
  end
end
