class Github::Repository::UpdateBranchProtection
  include Mandate

  initialize_with :repo, :branch, :additional_checks, :required_approving_review_count

  def call
    Exercism.octokit_client.protect_branch(repo, branch, new_protection)
  end

  private
  memoize
  def protection
    Exercism.octokit_client.branch_protection(repo, branch, accept: ACCEPT_HEADER).to_h
  rescue Octokit::NotFound
    {}
  end

  memoize
  def new_protection
    {
      accept: ACCEPT_HEADER,
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
  end

  ACCEPT_HEADER = 'application/vnd.github.v3+json'.freeze
  private_constant :ACCEPT_HEADER
end
