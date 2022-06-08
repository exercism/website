require 'test_helper'

class User::Activities::StartedExerciseActivityTest < ActiveSupport::TestCase
  test "keys" do
    user = create :user
    exercise = create(:concept_exercise)
    solution = create(:concept_solution, exercise:)

    activity = User::Activities::StartedExerciseActivity.create!(
      user:,
      track: exercise.track,
      solution:
    )
    assert_equal "#{user.id}|started_exercise|Solution##{solution.id}",
      activity.uniqueness_key
  end

  test "rendering_data is valid" do
    freeze_time do
      user = create :user
      exercise = create(:concept_exercise)
      solution = create(:concept_solution, exercise:, created_at: Time.current - 1.week)

      activity = User::Activities::StartedExerciseActivity.create!(
        user:,
        track: exercise.track,
        solution:
      )
      assert_equal "/tracks/ruby/exercises/strings", activity.rendering_data[:url]
      assert_equal "You started <strong>Strings</strong>", activity.rendering_data[:text]
      assert_equal Time.current - 1.week, activity.rendering_data[:occurred_at]
    end
  end
end
