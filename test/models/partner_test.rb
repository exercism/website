require "test_helper"

class PartnerTest < ActiveSupport::TestCase
  test "parses markdown to html on save" do
    partner = build :partner, description_markdown: "Hello"

    partner.save

    assert_equal "<p>Hello</p>\n", partner.description_html
  end
end
