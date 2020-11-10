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
end
