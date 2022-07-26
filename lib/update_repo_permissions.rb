# This script does a couple of things:
# 1. The branch protection settings of the track and track tooling repos are set.
# 2. The @maintainers-admin team is added to all track and tooling repos (with 'maintain' permissions).
# 3. The @reviewers team is added to all track and tooling repos (with 'push' permissions) if the track
#    team has less than two members.
#    This causes each member of the @reviewers team to automatically be notified of any changes in those repos.
#    They can unsubscribe from notifications for a repo using either the GitHub interface, curl or the GitHub CLI.
#
#    Example: curl
#    > curl -X PUT -H "Authorization: token $GITHUB_TOKEN" -H 'Content-Type: application/json' -d '{"ignored": true}' https://api.github.com/repos/exercism/csharp/subscription
#
#    Example: GH CLI
#    > gh api /repos/exercism/csharp/subscription --method PUT --field ignored=true

# rubocop:disable Rails/Output
def repos_with_tag(tag)
  Exercism.octokit_client.
    search_repositories("org:exercism topic:#{tag}").
    items.
    map(&:full_name).
    sort
end

track_repos = repos_with_tag('exercism-track')
tooling_repos = repos_with_tag('exercism-tooling')

TrackWithRepos = Struct.new(:slug, :repo, :tooling_repos, :active)
tracks = track_repos.map do |track_repo|
  slug = track_repo.split('/', 2).last
  track = Track.find_by(slug:)
  track_tooling_repos = %w[test-runner representer analyzer].
    map { |tooling_repo_suffix| "#{track_repo}-#{tooling_repo_suffix}" }.
    intersection(tooling_repos)
  TrackWithRepos.new(track&.slug, track_repo, track_tooling_repos, track&.active?)
end

active_tracks, inactive_tracks = tracks.partition(&:active)

def update_branch_protection(repo, additional_checks: [], required_approving_review_count: nil)
  branch = 'main'
  accept = 'application/vnd.github.v3+json'

  protection =
    begin
      Exercism.octokit_client.branch_protection(repo, branch, accept:).to_h
    rescue Octokit::NotFound
      {}
    end

  new_protection = {
    accept:,
    required_status_checks: {
      strict: false,
      checks: protection.dig(:required_status_checks, :checks).to_a.concat(additional_checks).uniq
    },
    enforce_admins: false, # We want admins to be able to override things
    required_pull_request_reviews: {
      dismissal_restrictions: {},
      dismiss_stale_reviews: false,
      require_code_owner_reviews: true, # We want to enforce code owner reviews
      required_approving_review_count:
        required_approving_review_count ||
        [protection.dig(:required_pull_request_reviews, :required_approving_review_count).to_i,
         1].max,
      bypass_pull_request_allowances: {
        users: [], # Disallow bypassing PR allowances for users
        teams: [] # Disallow bypassing PR allowances for teams
      }
    },
    restrictions: nil,
    required_linear_history: !!protection[:required_linear_history],
    allow_force_pushes: false, # We want to disable force pushing
    allow_deletions: false, # Don't allow deleting the branch
    block_creations: false,
    required_conversation_resolution: false
  }

  Exercism.octokit_client.protect_branch(repo, branch, new_protection)

  p "#{repo}: updated branch protection of #{branch} branch"
end

def update_active_repo_permissions(active_tracks)
  active_tracks.each do |active_track|
    configlet_check = { context: "configlet / configlet", app_id: 15_368 }
    update_branch_protection(active_track.repo, additional_checks: [configlet_check])

    active_track.tooling_repos.each do |tooling_repo|
      update_branch_protection(tooling_repo)
    end
  end
end

def update_inactive_repo_permissions(inactive_tracks)
  inactive_tracks.each do |inactive_track|
    update_branch_protection(inactive_track.repo, required_approving_review_count: 0)

    inactive_track.tooling_repos.each do |tooling_repo|
      update_branch_protection(tooling_repo, required_approving_review_count: 0)
    end
  end
end

def add_maintainers_admin_to_repos(repos)
  maintainers_admin_team = Exercism.octokit_client.team_by_name("exercism", "maintainers-admin")

  repos.each do |repo|
    Exercism.octokit_client.add_team_repository(maintainers_admin_team.id, "exercism/#{repo}", permission: :maintain)
    p "#{repo}: added @exercism/maintainers-admin team"
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
  reviewers_team = Exercism.octokit_client.team_by_name("exercism", "reviewers")

  active_tracks.each do |active_track|
    next unless tracks_with_few_maintainers.include?(active_track.slug)

    Exercism.octokit_client.add_team_repository(reviewers_team.id, active_track.repo, permission: :push)
    p "#{active_track.repo}: added @exercism/reviewers team"

    active_track.tooling_repos.each do |tooling_repo|
      Exercism.octokit_client.add_team_repository(reviewers_team.id, tooling_repo, permission: :push)
      p "#{tooling_repo}: added @exercism/reviewers team"
    end
  end
end

update_active_repo_permissions(active_tracks)
update_inactive_repo_permissions(inactive_tracks)
add_reviewers_team_to_active_tracks_with_few_maintainers(active_tracks)
add_maintainers_admin_to_repos(track_repos + tooling_repos)

# rubocop:enable Rails/Output
