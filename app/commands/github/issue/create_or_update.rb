class Github::Issue::CreateOrUpdate
  include Mandate

  initialize_with :node_id, attributes: Mandate::KWARGS

  def call
    issue = ::Github::Issue.create_or_find_by!(node_id:) do |i|
      i.number = attributes[:number]
      i.title = attributes[:title]
      i.status = status
      i.repo = attributes[:repo]
      i.opened_at = attributes[:opened_at]
      i.opened_by_username = attributes[:opened_by_username]
    end

    log_metric!(issue) if issue.just_created?

    issue.update!(
      number: attributes[:number],
      title: attributes[:title],
      status:,
      repo: attributes[:repo],
      opened_at: attributes[:opened_at],
      opened_by_username: attributes[:opened_by_username],
      labels: labels(issue)
    )

    issue
  end

  private
  def labels(issue)
    attributes[:labels].to_a.map do |label|
      Github::IssueLabel::CreateOrUpdate.(issue, label)
    end
  end

  def status = attributes[:state].downcase.to_sym

  def log_metric!(issue)
    Metric::Queue.(:open_issue, issue.opened_at, issue:, track:, user: opened_by_username)
  end

  def track = Track.for_repo(attributes[:repo])
  def opened_by_username = User.with_data.find_by(data: { github_username: attributes[:opened_by_username] })
end
