module Github
  class NotifyTrackSyncerAboutTrackChanges
    include Mandate

    initialize_with :track

    def call
      Exercism.octokit_client.post("https://api.github.com/repos/exercism/org-wide-files/dispatches", body)
    end

    private
    def body
      {
        event_type: 'track_changes',
        client_payload: {
          tracks: ["exercism/#{track.slug}"]
        }
      }.to_json
    end
  end
end
