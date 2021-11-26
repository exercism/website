require "test_helper"

class AssembleDocsTest < ActiveSupport::TestCase
  setup do
    Document::SearchDocs::Fallback.expects(:call).never
  end

  test "proxies correctly" do
    Document::SearchDocs.expects(:call).with(
      criteria: "foobar",
      track_slug: "fsharp",
      page: 15,
      per: 10
    ).returns(Document.page(15).per(10))

    params = {
      criteria: "foobar",
      track_slug: "fsharp",
      page: 15,
      per_page: 10
    }

    AssembleDocs.(params)
  end

  test "retrieves docs" do
    25.times do |_i|
      create :document
    end

    wait_for_opensearch_to_be_synced

    assert_equal SerializePaginatedCollection.(
      Document.page(1).per(25),
      serializer: SerializeDocs
    ), AssembleDocs.({})
  end
end
