require 'test_helper'

class ConceptSolutionTest < ActiveSupport::TestCase
  test "compact_uuid" do
    SecureRandom.expects(:uuid).returns("foo-bar-cat-dog")
    assert_equal "foobarcatdog", SecureRandom.compact_uuid
  end
end
