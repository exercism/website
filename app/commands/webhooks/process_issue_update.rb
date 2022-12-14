class Webhooks::ProcessIssueUpdate
  include Mandate

  initialize_with params: Mandate::KWARGS

  def call
    return unless valid_action?

    ProcessIssueUpdateJob.perform_later(params)
  end

  private
  def valid_action?
    %w[opened edited deleted closed reopened labeled unlabeled transferred].include?(params[:action])
  end
end
