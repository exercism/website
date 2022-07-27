# This module updates track and tooling repo permissions by:
# 1. Setting the branch protection of the track and track tooling repos.
# 2. Adding the @maintainers-admin team to all track and tooling repos (with 'maintain' permissions).
# 3. Adding the @reviewers team all track and tooling repos if their team has less than two members (with 'push' permissions).
#    This causes each member of the @reviewers team to automatically be notified of any changes in those repos.
#    They can unsubscribe from notifications for a repo using either the GitHub interface, curl or the GitHub CLI.
#
#    Example: curl
#    > curl -X PUT -H "Authorization: token $GITHUB_TOKEN" -H 'Content-Type: application/json' -d '{"ignored": true}' https://api.github.com/repos/exercism/csharp/subscription
#
#    Example: GH CLI
#    > gh api /repos/exercism/csharp/subscription --method PUT --field ignored=true
class Github::Repository::UpdatePermissionsForAllTrackRepositories
  include Mandate

  def call
    tracks_with_repos.each do |track_with_repos|
      Github::Repository::UpdateBranchProtectionForTrackRepositories(track_with_repos.repo, track_with_repos.tooling_repos,
        track_with_repos.active)
    end

    # add_reviewers_team_to_active_tracks_with_few_maintainers(active_tracks)
    # add_maintainers_admin_to_repos(track_repos + tooling_repos)
  end

  private
  TrackWithRepos = Struct.new(:slug, :repo, :tooling_repos, :active)

  def get_team(slug) = Exercism.octokit_client.team_by_name("exercism", slug)

  def add_team_to_repository(team, repo, permission)
    Exercism.octokit_client.add_team_repository(team.id, "exercism/#{repo}", permission:)
  end

  def add_maintainers_admin_to_repos(repos)
    maintainers_admin_team = get_team("maintainers-admin")

    repos.each do |repo|
      add_team_to_repository(maintainers_admin_team, repo, :maintain)
    end
  end

  def fetch_tracks_with_few_maintainers
    query = <<~QUERY
      query ($endCursor: String) {
        organization(login: "exercism") {
          team(slug: "track-maintainers") {
            childTeams(first: 50, after: $endCursor) {
              totalCount
              nodes {
                name
                members(first: 100) {
                  totalCount
                }
              }
              pageInfo {
                endCursor
              }
            }
          }
        }
      }#{'  '}
    QUERY

    end_cursor = nil
    teams = Set.new

    loop do
      variables = { endCursor: end_cursor }.to_json
      data = Exercism.octokit_client.post("https://api.github.com/graphql", { query:, variables: }.to_json).to_h

      data.dig(:data, :organization, :team, :childTeams, :nodes).each do |team|
        teams << team[:name] if team.dig(:members, :totalCount) <= 1
      end

      end_cursor = data.dig(:data, :organization, :team, :childTeams, :pageInfo, :endCursor)
      return teams.sort if end_cursor.nil?
    end
  end

  def add_reviewers_team_to_active_tracks_with_few_maintainers(active_tracks)
    tracks_with_few_maintainers = fetch_tracks_with_few_maintainers
    reviewers_team = get_team("reviewers")

    active_tracks.each do |active_track|
      next unless tracks_with_few_maintainers.include?(active_track.slug)

      add_team_to_repository(reviewers_team, active_track.repo, :push)

      active_track.tooling_repos.each do |tooling_repo|
        add_team_to_repository(reviewers_team, tooling_repo, :push)
      end
    end
  end

  memoize
  def track_repos = repos_with_tag('exercism-track')

  memoize
  def tooling_repos = repos_with_tag('exercism-tooling')

  def repos_with_tag(tag)
    Exercism.octokit_client.
      search_repositories("org:exercism topic:#{tag}").
      items.
      map(&:full_name).
      sort
  end

  memoize
  def active_tracks = tracks_with_repos.select(&:active)

  memoize
  def inactive_tracks = tracks_with_repos.reject(&:active)

  memoize
  def tracks_with_repos
    track_repos.map do |track_repo|
      slug = track_repo.split('/', 2).last
      track = Track.find_by(slug:)
      track_tooling_repos = %w[test-runner representer analyzer].
        map { |tooling_repo_suffix| "#{track_repo}-#{tooling_repo_suffix}" }.
        intersection(tooling_repos)
      TrackWithRepos.new(track&.slug, track_repo, track_tooling_repos, track&.active?)
    end
  end
end
