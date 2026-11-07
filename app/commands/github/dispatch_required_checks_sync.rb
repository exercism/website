# Asks exercism/maintainers-admin-tools to apply a repo's .github/required-checks.yml
# to the repo's ruleset. The workflow also runs daily, so a missed dispatch only delays it.
class Github::DispatchRequiredChecksSync
  include Mandate

  initialize_with :repo_name

  def call = Github::DispatchWorkflow.(REPO, WORKFLOW, inputs: { slug: repo_name })

  REPO = 'maintainers-admin-tools'.freeze
  WORKFLOW = 'update-track-maintenance-status.yml'.freeze
  private_constant :REPO, :WORKFLOW
end
