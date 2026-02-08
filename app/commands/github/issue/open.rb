class Github::Issue::Open
  include Mandate

  initialize_with :repo, :title, :body

  def call
    return if Rails.env.development?

    if missing?
      create_issue
    elsif closed?
      reopen_issue
    end
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  private
  def missing?
    issue.nil?
  end

  def closed?
    issue.state == "closed"
  end

  def create_issue
    Exercism.octokit_client.create_issue(repo, title, body)
  end

  def reopen_issue
    Exercism.octokit_client.reopen_issue(repo, issue.number)
  end

  memoize
  def issue
    author = Exercism.config.github_bot_username
    sanitized_title = title.gsub(/[{}]/, '')
    Exercism.octokit_client.search_issues(
      "\"#{sanitized_title}\" is:issue in:title repo:#{repo} author:#{author}"
    )[:items]&.first
  rescue Octokit::UnprocessableEntity
    nil
  end
end
