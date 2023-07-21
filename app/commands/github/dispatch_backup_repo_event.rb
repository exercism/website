class Github::DispatchBackupRepoEvent
  include Mandate

  initialize_with :repo

  def call = Exercism.octokit_client.post(API_URL, body)

  private
  def body
    {
      event_type: :backup_repo,
      client_payload: {
        repos: [repo]
      }
    }.to_json
  end

  API_URL = "https://api.github.com/repos/exercism/backup/dispatches".freeze
  private_constant :API_URL
end
