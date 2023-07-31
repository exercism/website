class User::ReputationToken::AwardForPullRequestReviewers
  include Mandate

  initialize_with params: Mandate::KWARGS

  def call
    return unless has_reviews?
    return unless just_closed?

    reviewer_usernames = params[:reviews].
      to_a.
      map { |reviewer| reviewer[:reviewer_username] }.
      compact.
      uniq

    # Don't award reviewer reputation to the PR author
    reviewer_usernames.delete(params[:author_username])

    # Only award reviewer reputation to organization members
    reviewer_usernames &= ::Github::OrganizationMember.pluck(:username)

    reviewers = ::User.with_data.where(data: { github_username: reviewer_usernames })
    reviewers.find_each do |reviewer|
      token = User::ReputationToken::Create.(
        reviewer,
        :code_review,
        level: reputation_level,
        repo: params[:repo],
        pr_node_id: params[:node_id],
        pr_number: params[:number],
        pr_title: params[:title],
        external_url: params[:html_url],
        merged_at: params[:merged_at],
        closed_at: params[:closed_at]
      )
      token&.update!(level: reputation_level)
    end

    # TODO: (Optional) consider what to do with missing reviewers
    missing_reviewers = reviewer_usernames - reviewers.map(&:github_username)
    Rails.logger.error "Missing reviewers: #{missing_reviewers.join(', ')}" if missing_reviewers.present?
  end

  private
  def has_reviews?
    params[:reviews].present?
  end

  def just_closed?
    params[:action] == 'closed'
  end

  def reputation_level
    # Sort descendingly to award greatest possible reputation
    %i[massive large medium small tiny].find do |type|
      params[:labels].include?(Github::IssueLabel.for_type(:size, type)) ||
        params[:labels].include?(Github::IssueLabel.for_type(:rep, type))
    end || :medium
  end
end
