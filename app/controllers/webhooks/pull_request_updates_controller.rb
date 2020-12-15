module Webhooks
  class PullRequestUpdatesController < BaseController
    def create
      ::Webhooks::ProcessPullRequestUpdate.(
        # params[:action] does not work as it is populated by Rails with the action method name
        request.request_parameters[:action],
        params[:pull_request][:user][:login],
        params[:pull_request][:url],
        params[:pull_request][:html_url],
        params[:pull_request][:labels].map { |label| label[:name] }
      )

      head :no_content
    end
  end
end
