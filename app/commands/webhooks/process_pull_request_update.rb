module Webhooks
  class ProcessPullRequestUpdate
    include Mandate

    initialize_with :pull_request_update

    def call
      log_open_metrics! if action_opened?
      log_merge_metrics! if action_closed? && merged?

      ProcessPullRequestUpdateJob.perform_later(params)
    end

    private
    def action_opened? = params[:action] == 'opened'
    def action_closed? = params[:action] == 'closed'
    def state_closed? = params[:state] == 'closed'
    def merged? = !!params[:merged]

    def valid_action? = %w[closed labeled unlabeled].include?(params[:action])

    def log_open_metrics!
      Metric::Queue.(:open_pull_request, params[:created_at], track:, user: author)
    end

    def log_merge_metrics!
      Metric::Queue.(:merge_pull_request, params[:merged_at], track:, user: merged_by)
    end

    def track = Track.for_repo(params[:repo])
    def author = User.find_by(github_username: params[:author_username])
    def merged_by = User.find_by(github_username: params[:merged_by_username])
  end
end
