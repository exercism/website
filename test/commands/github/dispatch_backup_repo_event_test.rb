require "test_helper"

class Github::DispatchBackupRepoEventTest < ActiveJob::TestCase
  test "dispatch repository event" do
    stub_request(:post, "https://api.github.com/repos/exercism/backup/dispatches").
      with(body: '{"event_type":"backup_repo","client_payload":{"repos":["exercism/ruby"]}}')

    Github::DispatchBackupRepoEvent.("exercism/ruby")
  end
end
