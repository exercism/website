require "test_helper"

class Github::Task::SyncTasksTest < ActiveSupport::TestCase
  test "syncs all issues" do
    issues = Array.new(25) { create :github_issue, :random }

    issues.each do |issue|
      Github::Task::SyncTask.expects(:call).with(issue)
    end

    Github::Task::SyncTasks.()
  end
end
