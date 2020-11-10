require 'test_helper'

class User::Activities::StartedExerciseActivityTest < ActiveSupport::TestCase
  test "keys" do
    user = create :user
    exercise = create(:concept_exercise)

    activity = User::Activities::StartedExerciseActivity.create!(
      user: user,
      track: exercise.track,
      params: { exercise: exercise }
    )
    assert_equal "#{user.id}|started_exercise|Exercise##{exercise.id}",
      activity.uniqueness_key

    assert_equal "#{user.id}|Exercise##{exercise.id}",
      activity.grouping_key
  end

  test "text is valid" do
    user = create :user
    exercise = create(:concept_exercise)

    activity = User::Activities::StartedExerciseActivity.create!(
      user: user,
      track: exercise.track,
      params: { exercise: exercise }
    )
    assert_equal "You started a new exercise", activity.text
  end
end
