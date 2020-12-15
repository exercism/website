module Webhooks
  class ProcessPullRequestUpdate
    include Mandate

    initialize_with :action, :github_username, :url, :html_url, :labels

    def call
      return unless handle_event?

      ProcessPullRequestUpdateJob.perform_later(action, github_username, url, html_url, labels)
    end

    private
    def handle_event?
      %w[closed labeled unlabeled].include?(action)
    end
  end
end
