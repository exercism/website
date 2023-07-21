class Github::DispatchOrgWideFilesRepoUpdateEvent
  include Mandate

  initialize_with :repo, :pusher_github_username

  def call
    Exercism.octokit_client.post("https://api.github.com/repos/exercism/org-wide-files/dispatches", body)
  end

  private
  def body
    {
      event_type: :repo_update,
      client_payload: {
        repos: [repo],
        pusher: pusher_github_username
      }
    }.to_json
  end
end
