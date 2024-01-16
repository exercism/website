require "test_helper"

class Solution::TagTest < ActiveSupport::TestCase
  test "wired correctly" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:)
    solution = create(:practice_solution, exercise:, user:)

    solution_tag = create(:solution_tag, solution:)

    assert_equal solution, solution_tag.solution
    assert_equal exercise, solution_tag.exercise
    assert_equal user, solution_tag.user
  end

  test "category" do
    tag = create :solution_tag, tag: 'construct:for-loop'
    assert_equal "construct", tag.category
  end

  test "name" do
    tag = create :solution_tag, tag: 'construct:for-loop'
    assert_equal "for-loop", tag.name
  end

  test "to_s" do
    tag = create :solution_tag, tag: 'construct:for-loop'
    assert_equal "Construct: For Loop", tag.to_s
  end
end
