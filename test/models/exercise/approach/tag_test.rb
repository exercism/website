require "test_helper"

class Exercise::Approach::TagTest < ActiveSupport::TestCase
  test "wired up correctly" do
    approach = create :exercise_approach
    tag = create(:exercise_approach_tag, approach:)

    assert_equal approach, tag.approach
    assert_equal [tag], approach.tags
  end
end
