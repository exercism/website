require "test_helper"

class SyncDocsJobTest < ActiveJob::TestCase
  test "docs are synced from git" do
    Git::SyncMainDocs.expects(:call)
    SyncDocsJob.perform_now
  end
end
