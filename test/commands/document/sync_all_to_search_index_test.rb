require "test_helper"

class Document::SyncAllToSearchIndexTest < ActiveSupport::TestCase
  setup do
    reset_opensearch!(Document::OPENSEARCH_INDEX)
  end

  test "indexes all documents" do
    tracks = [create(:track), nil]
    docs = build_list(:document, 2000, track: tracks.sample)

    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

    Document::SyncAllToSearchIndex.()

    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

    counts = Exercism.opensearch_client.count(index: Document::OPENSEARCH_INDEX)
    assert docs.size, counts["counts"]
  end

  test "indexes document linked to track" do
    track = create :track, id: 22, slug: 'nim', title: 'Nim'
    doc = create :document, id: 3, title: 'Installation', blurb: 'How to install Nim', track: track,
updated_at: Time.parse("2020-10-17T02:39:37.000Z").utc
    Document.any_instance.stubs(:markdown).returns('# Installation')
    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

    Document::SyncAllToSearchIndex.()

    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)
    indexed_doc = get_opensearch_doc(Document::OPENSEARCH_INDEX, doc.id)
    expected = {
      "_index" => "test-documents",
      "_type" => "document",
      "_id" => "3",
      "found" => true,
      "_source" => {
        "id" => 3,
        "title" => "Installation",
        "blurb" => "How to install Nim",
        "markdown" => "# Installation",
        "updated_at" => "2020-10-17T02:39:37.000Z",
        "track" => { "id" => 22, "slug" => "nim", "title" => "Nim" }
      }
    }

    assert_equal expected, indexed_doc.except("_version", "_seq_no", "_primary_term")
  end

  test "indexes document not linked to track" do
    doc = create :document, id: 4, title: 'Automated Feedback', blurb: 'Getting Automated Feedback',
updated_at: Time.parse("2020-10-17T02:39:37.000Z").utc
    Document.any_instance.stubs(:markdown).returns('# Automated Feedback')
    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

    Document::SyncAllToSearchIndex.()

    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)
    indexed_doc = get_opensearch_doc(Document::OPENSEARCH_INDEX, doc.id)
    expected = {
      "_index" => "test-documents",
      "_type" => "document",
      "_id" => "4",
      "found" => true,
      "_source" => {
        "id" => 4,
        "title" => "Automated Feedback",
        "blurb" => "Getting Automated Feedback",
        "markdown" => "# Automated Feedback",
        "updated_at" => "2020-10-17T02:39:37.000Z",
        "track" => nil
      }
    }

    assert_equal expected, indexed_doc.except("_version", "_seq_no", "_primary_term")
  end
end
