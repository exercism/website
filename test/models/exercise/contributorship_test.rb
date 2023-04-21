require "test_helper"

class Exercise::ContributorshipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    exercise = create :concept_exercise
    user = create :user
    contributorship = create :exercise_contributorship,
      exercise:,
      contributor: user

    assert_equal exercise, contributorship.exercise
    assert_equal user, contributorship.contributor
  end
end
