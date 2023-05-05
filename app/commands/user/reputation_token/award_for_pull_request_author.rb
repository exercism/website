class User::ReputationToken::AwardForPullRequestAuthor
  include Mandate

  initialize_with params: Mandate::KWARGS

  def call
    return unless has_author?
    return unless merged?

    user = User.with_data.find_by(data: { github_username: params[:author_username] })

    unless user
      # TODO: (Optional) decide what to do with user that cannot be found
      Rails.logger.error "Missing author: #{params[:author_username]}"
      return
    end

    token = User::ReputationToken::Create.(
      user,
      :code_contribution,
      level: reputation_level,
      repo: params[:repo],
      pr_node_id: params[:node_id],
      pr_number: params[:number],
      pr_title: params[:title],
      external_url: params[:html_url],
      merged_at: params[:merged_at]
    )
    token&.update!(level: reputation_level)
  end

  private
  def merged?
    params[:merged].present?
  end

  def has_author?
    params[:author_username].present?
  end

  def reputation_level
    # Sort descendingly to award greatest possible reputation
    %i[massive large medium small tiny].find do |type|
      params[:labels].include?(Github::IssueLabel.for_type(:size, type)) ||
        params[:labels].include?(Github::IssueLabel.for_type(:rep, type))
    end || :medium
  end
end
