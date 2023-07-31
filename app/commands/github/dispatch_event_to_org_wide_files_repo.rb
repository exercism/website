class Github::DispatchEventToOrgWideFilesRepo
  include Mandate

  initialize_with :event_type, :repos, :pusher_github_username

  def call
    raise "Unsupported event type" unless EVENT_TYPES.include?(event_type)

    Exercism.octokit_client.post("https://api.github.com/repos/exercism/org-wide-files/dispatches", body)
  end

  private
  def body
    {
      event_type: event_type.to_s,
      client_payload: {
        repos:,
        pusher: pusher_github_username
      }
    }.to_json
  end

  EVENT_TYPES = %i[repo_update].freeze
  private_constant :EVENT_TYPES
end
