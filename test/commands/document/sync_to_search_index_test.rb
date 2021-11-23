require "test_helper"

class Document::SyncToSearchIndexTest < ActiveSupport::TestCase
  setup do
    reset_opensearch!(Document::OPENSEARCH_INDEX)
  end

  test "indexes document linked to track" do
    track = create :track, id: 22, slug: 'nim', title: 'Nim'
    doc = create :document, id: 3, title: 'Installation', blurb: 'How to install Nim', track: track,
updated_at: Time.parse("2020-10-17T02:39:37.000Z").utc
    doc.stubs(:markdown).returns('# Installation')

    Document::SyncToSearchIndex.(doc)

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
    doc.stubs(:markdown).returns('# Automated Feedback')

    Document::SyncToSearchIndex.(doc)

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
