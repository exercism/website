require "test_helper"

class NotifyTrackOrgWideFileChangeJobTest < ActiveJob::TestCase
  test "dispatch repository event for track" do
    track = create :track, slug: 'ruby'

    stub_request(:post, "https://api.github.com/repos/exercism/org-wide-files/dispatches").
      with(body: '{"event_type":"track_changes","client_payload":{"tracks":["exercism/ruby"]}}')

    NotifyTrackOrgWideFileChangeJob.perform_now(track)

    assert_requested(:post, "https://api.github.com/repos/exercism/org-wide-files/dispatches", times: 1) do |req|
      req.body == '{"event_type":"track_changes","client_payload":{"tracks":["exercism/ruby"]}}'
    end
  end
end
