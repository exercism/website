require "test_helper"

class Exercise::TagTest < ActiveSupport::TestCase
  test "category" do
    tag = create :exercise_tag, tag: 'construct:for-loop'
    assert_equal "construct", tag.category
  end

  test "name" do
    tag = create :exercise_tag, tag: 'construct:for-loop'
    assert_equal "for-loop", tag.name
  end

  test "to_s" do
    tag = create :exercise_tag, tag: 'construct:for-loop'
    assert_equal "Construct: For Loop", tag.to_s
  end
end
