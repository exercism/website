class NotifyTrackOrgWideFileChangeJob < ApplicationJob
  queue_as :default

  def perform(track)
    body = {
      event_type: 'track_changes',
      client_payload: {
        tracks: ["exercism/#{track.slug}"]
      }
    }.to_json
    Exercism.octokit_client.post("https://api.github.com/repos/exercism/org-wide-files/dispatches", body)
  end
end
