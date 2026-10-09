require "test_helper"

class Document::RemoveFromSearchIndexTest < ActiveSupport::TestCase
  test "a destroyed document is removed from the search index" do
    doc = create :document
    Document::SyncToSearchIndex.(doc)
    wait_for_opensearch_to_be_synced

    doc.destroy!
    Document::RemoveFromSearchIndex.(doc.id)
    wait_for_opensearch_to_be_synced

    refute Exercism.opensearch_client.exists(index: Document::OPENSEARCH_INDEX, id: doc.id)
  end

  test "removing a document that was never indexed does nothing" do
    Document::RemoveFromSearchIndex.(123_456)
  end
end
