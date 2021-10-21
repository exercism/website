require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "content_html renders correctly" do
    doc = create :document
    assert doc.content_html.starts_with?("<h2 id=\"h-running-tests\">Running Tests</h2>\n<p>Execute the tests with:</p>")
  end
end
