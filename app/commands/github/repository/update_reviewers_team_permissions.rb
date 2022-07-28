class Github::Repository::UpdateReviewersTeamPermissions
  include Mandate

  initialize_with :repos

  def call
    repos.each do |repo|
      next unless active_tracks_with_few_maintainers.include?(repo.track)

      Exercism.octokit_client.add_team_repository(reviewers_team.id, repo.name_with_owner, permission: :push)
    end
  end

  private
  memoize
  def reviewers_team
    Exercism.octokit_client.team_by_name("exercism", "reviewers")
  end

  memoize
  def active_tracks_with_few_maintainers
    track_teams_with_few_maintainers = track_teams_with_num_members.filter_map { |team, num_members| team if num_members <= 1 }
    Track.where(active: true, slug: track_teams_with_few_maintainers)
  end

  def track_teams_with_num_members
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
    teams = {}

    loop do
      variables = { endCursor: end_cursor }.to_json
      data = Exercism.octokit_client.post("https://api.github.com/graphql", { query:, variables: }.to_json).to_h

      data.dig(:data, :organization, :team, :childTeams, :nodes).each do |team|
        teams[team[:name]] = team.dig(:members, :totalCount)
      end

      end_cursor = data.dig(:data, :organization, :team, :childTeams, :pageInfo, :endCursor)
      return teams if end_cursor.nil?
    end
  end
end
