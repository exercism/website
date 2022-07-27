class Github::Repository::UpdateSettings
  include Mandate

  def call
    Github::Repository::UpdateBranchProtection.(repos)
    Github::Repository::UpdateTeams.(repos)
  end

  private
  memoize
  def repos = track_repos + tooling_repos

  def track_repos = repos_with_tag('exercism-track', :track)
  def tooling_repos = repos_with_tag('exercism-tooling', :tooling)

  def repos_with_tag(tag, type)
    Exercism.octokit_client.
      search_repositories("org:exercism topic:#{tag}").
      items.
      map(&:name).
      sort.
      map { |name| Github::Repository.new(name, type) }
  end
end
