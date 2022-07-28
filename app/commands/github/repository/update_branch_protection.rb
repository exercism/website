class Github::Repository::UpdateBranchProtection
  include Mandate

  initialize_with :repos

  def call
    repos.each do |repo|
      update_branch_protection_settings(repo)
    end
  end

  private
  def update_branch_protection_settings(repo)
    branch_protection_settings = new_branch_protection_settings(repo)
    Exercism.octokit_client.protect_branch(repo.name_with_owner, BRANCH, branch_protection_settings)
  end

  def new_branch_protection_settings(repo)
    existing_settings = get_branch_protection_settings(repo)

    checks = existing_settings.dig(:required_status_checks, :checks).to_a
    checks.push(CONFIGLET_CHECK) if repo.type == :track

    required_approving_review_count = existing_settings.dig(:required_pull_request_reviews, :required_approving_review_count).to_i
    required_approving_review_count = repo.track.active? ? [required_approving_review_count, 1].max : 0

    required_linear_history = !!existing_settings.dig(:required_linear_history, :enabled)

    {
      accept: ACCEPT_HEADER,
      required_status_checks: {
        strict: false,
        checks:
      },
      enforce_admins: false, # We want admins to be able to override things
      required_pull_request_reviews: {
        dismissal_restrictions: {},
        dismiss_stale_reviews: false,
        require_code_owner_reviews: true, # We want to enforce code owner reviews
        required_approving_review_count:,
        bypass_pull_request_allowances: {
          users: [], # Disallow bypassing PR allowances for users
          teams: [] # Disallow bypassing PR allowances for teams
        }
      },
      restrictions: nil,
      required_linear_history:,
      allow_force_pushes: false, # We want to disable force pushing
      allow_deletions: false, # Don't allow deleting the branch
      block_creations: false,
      required_conversation_resolution: false
    }
  end

  def get_branch_protection_settings(track_repository)
    Exercism.octokit_client.branch_protection(track_repository.name_with_owner, BRANCH, accept: ACCEPT_HEADER).to_h
  rescue Octokit::NotFound
    {}
  end

  BRANCH = 'main'.freeze
  ACCEPT_HEADER = 'application/vnd.github.v3+json'.freeze
  CONFIGLET_CHECK = { context: "configlet / configlet", app_id: 15_368 }.freeze
  private_constant :BRANCH, :ACCEPT_HEADER, :CONFIGLET_CHECK
end
