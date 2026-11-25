# Asks exercism/maintenance to apply a repo's .github/required-checks.yml
# to the repo's ruleset. The workflow also runs daily, so a missed dispatch only delays it.
class Github::DispatchRequiredChecksSync
  include Mandate

  initialize_with :repo_name

  def call = Github::DispatchWorkflow.(REPO, WORKFLOW, inputs: { slug: repo_name })

  REPO = 'maintenance'.freeze
  WORKFLOW = 'sync-repo-settings.yml'.freeze
  private_constant :REPO, :WORKFLOW
end
