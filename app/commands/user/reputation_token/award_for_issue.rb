class User::ReputationToken::AwardForIssue
  include Mandate

  initialize_with params: Mandate::KWARGS

  def call
    return unless label_change?
    return unless author

    if reputation_level
      create_token!
    else
      delete_token!
    end
  end

  private
  def label_change?
    %w[labeled unlabeled].include?(params[:action])
  end

  memoize
  def reputation_level
    # Sort descendingly to award greatest possible reputation
    %i[massive large].find do |type|
      params[:labels].include?(Github::IssueLabel.for_type(:rep, type))
    end
  end

  memoize
  def author
    User.with_data.find_by(data: { github_username: params[:opened_by_username] })
  end

  def create_token!
    User::ReputationToken::Create.(
      author,
      :issue_author,
      level: reputation_level,
      repo: params[:repo],
      issue_node_id: params[:node_id],
      issue_number: params[:number],
      issue_title: params[:title],
      external_url: params[:html_url],
      opened_at: params[:opened_at]
    )&.tap do |token|
      token.update!(level: reputation_level)
    end
  end

  def delete_token!
    User::ReputationTokens::IssueAuthorToken.find_by(user: author, external_url: params[:html_url])&.tap do |token|
      User::ReputationToken::Destroy.(token)
    end
  end
end
