def repos_with_tag(tag)
  Exercism.octokit_client.
    search_repositories("org:exercism topic:#{tag}").
    items.
    map(&:full_name).
    sort
end

track_repos = repos_with_tag('exercism-track')
tooling_repos = repos_with_tag('exercism-tooling')

TrackWithRepos = Struct.new(:repo, :tooling_repos, :active)
tracks = track_repos.map do |track_repo|
  active = Track.for_repo(track_repo)&.active?
  track_tooling_repos = %w[test-runner representer analyzer].
    map { |tooling_repo_suffix| "#{track_repo}-#{tooling_repo_suffix}" }.
    intersection(tooling_repos)
  TrackWithRepos.new(track_repo, track_tooling_repos, active)
end

_active_tracks, _inactive_tracks = tracks.partition(&:active)

def update_repo_permissions(repo, additional_checks = [])
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
      required_approving_review_count: [protection.dig(:required_pull_request_reviews, :required_approving_review_count).to_i,
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

  client.protect_branch(repo, branch, new_protection)

  # rubocop:disable Rails/Output
  p "#{repo}: updated"
  # rubocop:enable Rails/Output
end

def update_active_repo_permissions(active_tracks)
  active_tracks.each do |active_track|
    configlet_check = { context: "configlet / configlet", app_id: 15_368 }
    update_repo_permissions(active_track.repo, [configlet_check])

    active_track.tooling_repos.each do |tooling_repo|
      update_repo_permissions(tooling_repo)
    end
  end
end

def update_inactive_repo_permissions(inactive_tracks)
  # TODO: consider what permissions to use for inactive repos
  # We'll want them to be able to merge pull requests without
  # approval, but we'll probably want to keep the other settings
end
