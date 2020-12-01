require 'test_helper'

class User::Activities::SubmittedIterationActivityTest < ActiveSupport::TestCase
  test "keys" do
    user = create :user
    exercise = create :concept_exercise
    solution = create :concept_solution, user: user, exercise: exercise
    iteration = create :iteration, solution: solution

    activity = User::Activities::SubmittedIterationActivity.create!(
      user: user,
      track: exercise.track,
      params: {
        iteration: iteration,
        exercise: exercise
      }
    )
    assert_equal "#{user.id}|submitted_iteration|Iteration##{iteration.id}",
      activity.uniqueness_key

    assert_equal "#{user.id}|Exercise##{exercise.id}",
      activity.grouping_key
  end

  test "rendering_data is valid" do
    freeze_time do
      user = create :user
      exercise = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: exercise
      iteration = create :iteration, solution: solution

      activity = User::Activities::SubmittedIterationActivity.create!(
        user: user,
        track: exercise.track,
        params: {
          iteration: iteration,
          exercise: exercise
        }
      )

      assert_equal exercise.title, activity.rendering_data.exercise_title
      assert_equal exercise.icon_name, activity.rendering_data.exercise_icon_name
      assert_equal "/tracks/csharp/exercises/datetime/iterations?idx=0", activity.rendering_data.url
      assert_equal "You submitted an iteration to", activity.rendering_data.text
      assert_equal Time.current, activity.rendering_data.occurred_at
    end
  end
end
