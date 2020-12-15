module Webhooks
  class ProcessPullRequestUpdate
    include Mandate

    initialize_with :action, :github_username, :params

    def call
      return unless handle_event?

      ProcessPullRequestUpdateJob.perform_later(action, github_username, params)
    end

    private
    def handle_event?
      %w[closed labeled unlabeled].include?(action)
    end
  end
end
