class Github::PullRequest::CreateOrUpdate
  include Mandate

  initialize_with :node_id, attributes: Mandate::KWARGS

  def call
    pull_request = ::Github::PullRequest.create_or_find_by!(node_id:) do |pr|
      pr.attributes = attributes.except(:reviews)
    end

    log_open_metrics!(pull_request) if pull_request.just_created?
    log_merge_metrics!(pull_request) if pull_request.just_created? && pull_request.merged?

    pull_request.tap do |pr|
      pr.update!(attributes.merge(reviews: reviews(pr)))

      log_merge_metrics!(pr) if pr.state_previously_changed? && pr.merged?
    end
  end

  private
  def reviews(pull_request)
    attributes[:reviews].to_a.map do |review|
      Github::PullRequestReview::CreateOrUpdate.(pull_request, review[:node_id], review[:reviewer_username])
    end
  end

  def log_open_metrics!(pull_request)
    Metric::Queue.(:open_pull_request, pull_request.data[:created_at], pull_request:, track: track(pull_request),
      user: author(pull_request))
  end

  def log_merge_metrics!(pull_request)
    Metric::Queue.(:merge_pull_request, pull_request.data[:merged_at], pull_request:, track: track(pull_request),
      user: merged_by(pull_request))
  end

  def track(pull_request) = Track.for_repo(pull_request.repo)
  def author(pull_request) = User.with_data.find_by(data: { github_username: pull_request.author_username })
  def merged_by(pull_request) = User.with_data.find_by(data: { github_username: pull_request.merged_by_username })
end
