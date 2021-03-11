module Webhooks
  class ProcessPullRequestUpdate
    include Mandate

    initialize_with :params

    def call
      return unless closed?
      return unless valid_action?

      ProcessPullRequestUpdateJob.perform_later(params)
    end

    private
    def closed?
      params[:state] == 'closed'
    end

    def valid_action?
      %w[closed labeled unlabeled].include?(params[:action])
    end
  end
end
