require "test_helper"

class Site::TagTest < ActiveSupport::TestCase
  test "category" do
    tag = create :site_tag, tag: "construct:if"
    assert_equal "construct", tag.category
  end

  test "name" do
    tag = create :site_tag, tag: "construct:if"
    assert_equal "if", tag.name
  end
end
