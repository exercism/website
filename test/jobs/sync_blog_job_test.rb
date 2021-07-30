require "test_helper"

class SyncBlogJobTest < ActiveJob::TestCase
  test "track is synced from git" do
    Git::SyncBlog.expects(:call)
    SyncBlogJob.perform_now
  end
end
