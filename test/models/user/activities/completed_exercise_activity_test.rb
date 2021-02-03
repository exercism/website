require 'test_helper'

class User::Activities::CompletedExerciseActivityTest < ActiveSupport::TestCase
  test "keys" do
    user = create :user
    exercise = create(:concept_exercise)
    solution = create(:concept_solution, exercise: exercise, completed_at: Time.current)

    activity = User::Activities::CompletedExerciseActivity.create!(
      user: user,
      track: exercise.track,
      solution: solution
    )
    assert_equal "#{user.id}|completed_exercise|Solution##{solution.id}",
      activity.uniqueness_key
  end

  test "rendering_data is valid" do
    freeze_time do
      user = create :user
      exercise = create(:concept_exercise)
      solution = create(:concept_solution, exercise: exercise, completed_at: Time.current - 1.week)

      activity = User::Activities::CompletedExerciseActivity.create!(
        user: user,
        track: exercise.track,
        solution: solution
      )
      assert_equal "/tracks/ruby/exercises/strings", activity.rendering_data[:url]
      assert_equal "You completed an exercise", activity.rendering_data[:text]
      assert_equal Time.current - 1.week, activity.rendering_data[:occurred_at]
    end
  end
end
