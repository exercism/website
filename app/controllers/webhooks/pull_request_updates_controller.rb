module Webhooks
  class PullRequestUpdatesController < BaseController
    def create
      ::Webhooks::ProcessPullRequestUpdate.(
        # params[:action] does not work as it is populated by Rails with the action method name
        action: request.request_parameters[:action],
        author_username: params[:pull_request][:user][:login],
        url: params[:pull_request][:url],
        html_url: params[:pull_request][:html_url],
        labels: params[:pull_request][:labels].map { |label| label[:name] },
        state: params[:pull_request][:state],
        node_id: params[:pull_request][:node_id],
        number: params[:pull_request][:number],
        title: params[:pull_request][:title],
        repo: params[:repository][:full_name],
        created_at: params[:pull_request][:created_at].present? ? Time.parse(params[:pull_request][:created_at]).utc : nil,
        merged_at: params[:pull_request][:merged_at].present? ? Time.parse(params[:pull_request][:merged_at]).utc : nil,
        merged: params[:pull_request][:merged],
        merged_by_username: params[:pull_request][:merged_by].present? ? params[:pull_request][:merged_by][:login] : nil
      )

      head :no_content
    end
  end
end
