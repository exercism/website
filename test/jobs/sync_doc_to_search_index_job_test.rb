require "test_helper"

class SyncDocToSearchIndexJobTest < ActiveJob::TestCase
  test "document is indexed" do
    doc = create :document
    Document::SyncToSearchIndex.expects(:call).with(doc)

    SyncDocToSearchIndexJob.perform_now(doc)
  end
end
