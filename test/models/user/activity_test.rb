require "test_helper"

class User::ActivityTest < ActiveSupport::TestCase
  test "creates correctly" do
    freeze_time do
      user = create :user
      exercise = create(:concept_exercise)
      track = exercise.track

      activity = User::Activities::StartedExerciseActivity.create!(
        user: user,
        track: track,
        params: {
          exercise: exercise
        }
      )

      assert_equal user, activity.user
      assert_equal track, activity.track
      assert_equal Time.current, activity.occurred_at
    end
  end

  test "rendering data reads cache" do
    user = create :user
    exercise = create(:concept_exercise)

    User::Activities::StartedExerciseActivity.create!(
      user: user,
      track: exercise.track,
      params: {
        exercise: exercise
      }
    )

    # Reload it to check nothing is memoized
    activity = User::Activity.last
    activity.expects(:cachable_rendering_data).never

    cache_data = {
      'exercise_icon_name' => exercise.icon_name,
      'exercise_title' => exercise.title,
      'url' => "/tracks/csharp/exercises/strings",
      'text' => "You started a new exercise"
    }
    assert_equal cache_data, activity.rendering_data_cache
    assert_equal exercise.title, activity.rendering_data.exercise_title
    assert_equal exercise.icon_name, activity.rendering_data.exercise_icon_name
    assert_equal "/tracks/csharp/exercises/strings", activity.rendering_data.url
    assert_equal "You started a new exercise", activity.rendering_data.text
    assert_equal Time.current, activity.rendering_data.occurred_at
  end

  test "rendering data rebuilds if cache is empty" do
    freeze_time do
      user = create :user
      exercise = create(:concept_exercise)

      activity = User::Activities::StartedExerciseActivity.create!(
        user: user,
        track: exercise.track,
        params: {
          exercise: exercise
        }
      )
      activity.update!(rendering_data_cache: {})

      # Reload it to check nothing is memoized
      activity = User::Activity.last
      assert_equal({}, activity.rendering_data_cache)
      assert_equal exercise.title, activity.rendering_data.exercise_title
      assert_equal exercise.icon_name, activity.rendering_data.exercise_icon_name
      assert_equal "/tracks/csharp/exercises/strings", activity.rendering_data.url
      assert_equal "You started a new exercise", activity.rendering_data.text
      assert_equal Time.current, activity.rendering_data.occurred_at

      activity = User::Activity.last
      cache_data = {
        'exercise_icon_name' => exercise.icon_name,
        'exercise_title' => exercise.title,
        'url' => "/tracks/csharp/exercises/strings",
        'text' => "You started a new exercise"
      }
      assert_equal cache_data, activity.rendering_data_cache
    end
  end
end
