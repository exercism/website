class User::ReputationToken::AwardForPullRequestMerger
  include Mandate

  initialize_with params: Mandate::KWARGS

  def call
    return unless merged?
    return if merged_by_author?

    user = User.with_data.find_by(data: { github_username: params[:merged_by_username] })

    unless user
      # TODO: (Optional) decide what to do with user that cannot be found
      Rails.logger.error "Missing merged by user: #{params[:merged_by_username]}"
      return
    end

    token = User::ReputationToken::Create.(
      user,
      :code_merge,
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
    params[:merged].present? && params[:merged_by_username].present?
  end

  def merged_by_author?
    params[:merged_by_username] == params[:author_username]
  end

  def reputation_level
    return :janitorial if params[:reviews].present?

    :reviewal
  end
end
