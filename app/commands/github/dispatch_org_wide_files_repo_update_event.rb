class Github::DispatchOrgWideFilesRepoUpdateEvent
  include Mandate

  initialize_with :repo, :pusher_github_username

  def call = Github::DispatchEvent.(REPO, EVENT_TYPE, client_payload)

  private
  def client_payload = { repos: [repo], pusher: pusher_github_username }

  REPO = 'org-wide-files'.freeze
  EVENT_TYPE = 'repo_update'.freeze
  private_constant :REPO, :EVENT_TYPE
end
