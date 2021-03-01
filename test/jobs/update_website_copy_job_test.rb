require "test_helper"

class UpdateWebsiteCopyJobTest < ActiveJob::TestCase
  test "track is synced from git" do
    Git::WebsiteCopy.expects(:update!)
    UpdateWebsiteCopyJob.perform_now
  end
end
