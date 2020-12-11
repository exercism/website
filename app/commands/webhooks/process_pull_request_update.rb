module Webhooks
  class ProcessPullRequestUpdate
    include Mandate

    initialize_with :action, :author, :url, :html_url

    def call
      return unless handle_event?

      ProcessPullRequestUpdateJob.perform_later(action, author, url, html_url)
    end

    private
    def handle_event?
      %w[closed labeled unlabeled].include?(action)
    end
  end
end
