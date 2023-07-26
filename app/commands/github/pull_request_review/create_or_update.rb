class Github::PullRequestReview::CreateOrUpdate
  include Mandate

  initialize_with :pull_request, :node_id, :reviewer_username

  def call
    review = ::Github::PullRequestReview.create_or_find_by!(node_id:) do |r|
      r.pull_request = pull_request
      r.reviewer_username = reviewer_username
    end

    review.update!(reviewer_username:)
    review
  end
end
