class Github::Repository::UpdateSettings
  include Mandate

  def call
    Github::Repository::UpdateBranchProtection.(repos)
    Github::Repository::UpdateMaintainersAdminTeamPermissions.(repos)
    Github::Repository::UpdateReviewersTeamPermissions.(repos)
  end

  private
  memoize
  def repos = (track_repos + tooling_repos).sort

  def track_repos = repos_with_tag('exercism-track', :track)
  def tooling_repos = repos_with_tag('exercism-tooling', :tooling)

  def repos_with_tag(tag, type)
    Exercism.octokit_client.
      search_repositories("org:exercism topic:#{tag}").
      items.
      map { |repo| Github::Repository.new(repo.name, type) }
  end
end
