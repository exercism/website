module Webhooks
  class PullRequestUpdatesController < BaseController
    def create
      ::Webhooks::ProcessPullRequestUpdate.(action, github_username,
        url: url,
        html_url: html_url,
        labels: labels,
        state: state)

      head :no_content
    end

    private
    def action
      # params[:action] does not work as it is populated by Rails with the action method name
      request.request_parameters[:action]
    end

    def github_username
      params[:pull_request][:user][:login]
    end

    def url
      params[:pull_request][:url]
    end

    def html_url
      params[:pull_request][:html_url]
    end

    def labels
      params[:pull_request][:labels].map { |label| label[:name] }
    end

    def state
      params[:pull_request][:state]
    end
  end
end
