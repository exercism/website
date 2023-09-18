require "test_helper"

class Exercise::AuthorshipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    exercise = create :concept_exercise
    user = create :user
    authorship = create :exercise_authorship,
      exercise:,
      author: user

    assert_equal exercise, authorship.exercise
    assert_equal user, authorship.author
  end
end
