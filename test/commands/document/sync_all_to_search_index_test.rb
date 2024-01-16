require "test_helper"

class Document::SyncAllToSearchIndexTest < ActiveSupport::TestCase
  test "indexes all documents" do
    tracks = [create(:track), nil]
    docs = build_list(:document, 2000, track: tracks.sample)

    wait_for_opensearch_to_be_synced

    Document::SyncAllToSearchIndex.()

    wait_for_opensearch_to_be_synced

    counts = Exercism.opensearch_client.count(index: Document::OPENSEARCH_INDEX)
    assert docs.size, counts["counts"]
  end

  test "indexes document linked to track" do
    track = create :track, slug: 'nim'
    doc = create(:document, id: 3, title: 'Installation', blurb: 'How to install Nim', track:)
    Document.any_instance.stubs(:markdown).returns('# Installation')
    wait_for_opensearch_to_be_synced

    Document::SyncAllToSearchIndex.()

    wait_for_opensearch_to_be_synced
    indexed_doc = get_opensearch_doc(Document::OPENSEARCH_INDEX, doc.id)
    expected = {
      "_index" => "test-documents",
      "_id" => "3",
      "found" => true,
      "_source" => {
        "id" => 3,
        "title" => "Installation",
        "blurb" => "How to install Nim",
        "markdown" => "# Installation",
        "track" => { "slug" => "nim" }
      }
    }

    assert_equal expected, indexed_doc.except("_version", "_seq_no", "_primary_term")
  end

  test "indexes document not linked to track" do
    doc = create :document, id: 4, title: 'Automated Feedback', blurb: 'Getting Automated Feedback'
    Document.any_instance.stubs(:markdown).returns('# Automated Feedback')
    wait_for_opensearch_to_be_synced

    Document::SyncAllToSearchIndex.()

    wait_for_opensearch_to_be_synced
    indexed_doc = get_opensearch_doc(Document::OPENSEARCH_INDEX, doc.id)
    expected = {
      "_index" => "test-documents",
      "_id" => "4",
      "found" => true,
      "_source" => {
        "id" => 4,
        "title" => "Automated Feedback",
        "blurb" => "Getting Automated Feedback",
        "markdown" => "# Automated Feedback",
        "track" => nil
      }
    }

    assert_equal expected, indexed_doc.except("_version", "_seq_no", "_primary_term")
  end
end
