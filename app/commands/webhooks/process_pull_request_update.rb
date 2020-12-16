module Webhooks
  class ProcessPullRequestUpdate
    include Mandate

    initialize_with :action, :github_username, :params

    def call
      return unless closed?
      return unless valid_action?

      ProcessPullRequestUpdateJob.perform_later(action, github_username, params)
    end

    private
    def closed?
      params[:state] == 'closed'
    end

    def valid_action?
      %w[closed labeled unlabeled].include?(action)
    end
  end
end
