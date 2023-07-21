require "test_helper"

class Github::DispatchOrgWideFilesRepoUpdateEventTest < ActiveJob::TestCase
  test "dispatch repo update event" do
    stub_request(:post, "https://api.github.com/repos/exercism/org-wide-files/dispatches").
      with(body: '{"event_type":"repo_update","client_payload":{"repos":["exercism/ruby"],"pusher":"user17"}}')

    Github::DispatchOrgWideFilesRepoUpdateEvent.("exercism/ruby", 'user17')
  end
end
