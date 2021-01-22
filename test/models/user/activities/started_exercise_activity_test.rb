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

  test "rendering_data is valid" do
    freeze_time do
      user = create :user
      exercise = create(:concept_exercise)

      activity = User::Activities::StartedExerciseActivity.create!(
        user: user,
        track: exercise.track,
        params: { exercise: exercise }
      )
      assert_equal exercise.title, activity.rendering_data.exercise_title
      assert_equal exercise.icon_name, activity.rendering_data.exercise_icon_name
      assert_equal "/tracks/csharp/exercises/strings", activity.rendering_data.url
      assert_equal "You started a new exercise", activity.rendering_data.text
      assert_equal Time.current, activity.rendering_data.occurred_at
    end
  end
end
