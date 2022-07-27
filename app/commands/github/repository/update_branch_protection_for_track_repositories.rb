class Github::Repository::UpdateBranchProtectionForTrackRepositories
  include Mandate

  initialize_with :track_repo, :track_tooling_repos, :active

  def call
    Github::Repository::UpdateBranchProtection.(track_repo, BRANCH, additional_checks: track_repo_additional_checks,
      required_approving_review_count:)

    track_tooling_repos.each do |track_tooling_repo|
      Github::Repository::UpdateBranchProtection.(track_tooling_repo, BRANCH, additional_checks: [], required_approving_review_count:)
    end
  end

  private
  def track_repo_additional_checks = active ? [CONFIGLET_CHECK] : []
  def required_approving_review_count = active ? nil : 0

  BRANCH = 'main'.freeze
  CONFIGLET_CHECK = { context: "configlet / configlet", app_id: 15_368 }.freeze
  private_constant :BRANCH, :CONFIGLET_CHECK
end
