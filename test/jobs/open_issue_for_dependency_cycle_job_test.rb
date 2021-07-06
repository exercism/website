require "test_helper"

class OpenIssueForDependencyCycleJobTest < ActiveJob::TestCase
  test "opens issue" do
    track = create :track

    Github::Issue::OpenForDependencyCycle.expects(:call).with(track)

    OpenIssueForDependencyCycleJob.perform_now(track)
  end
end
