require "test_helper"

class Github::DispatchRequiredChecksSyncTest < ActiveJob::TestCase
  test "dispatches the maintenance status workflow for the repo" do
    stub_request(:post, "https://api.github.com/repos/exercism/maintainers-admin-tools/actions/workflows/sync-repo-settings.yml/dispatches").
      with(body: '{"ref":"main","inputs":{"slug":"ruby-test-runner"}}')

    Github::DispatchRequiredChecksSync.("ruby-test-runner")
  end
end
