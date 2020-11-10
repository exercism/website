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

  test "text is valid" do
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
    assert_equal "You submitted an iteration to", activity.text
  end
end
