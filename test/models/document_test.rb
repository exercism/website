require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "content_html renders correctly" do
    doc = create :document
    assert doc.content_html.starts_with?("<h2 id=\"h-running-tests\">Running Tests</h2>\n<p>Execute the tests with:</p>")
  end

  test "creating document enqueues job to sync document to search index" do
    assert_enqueued_with(job: MandateJob, args: ->(job_args) { job_args[0] == Document::SyncToSearchIndex.name }) do
      create :document
    end
  end

  test "updating document enqueues job to sync document to search index" do
    doc = create :document

    assert_enqueued_with(job: MandateJob, args: [Document::SyncToSearchIndex.name, doc]) do
      doc.update!(title: 'new-title')
    end
  end

  test "sorted scope sorts by position" do
    doc_1 = create :document, position: 3
    doc_2 = create :document, position: 1
    doc_3 = create :document, position: 2

    assert_equal [doc_2, doc_3, doc_1], Document.sorted
  end
end
