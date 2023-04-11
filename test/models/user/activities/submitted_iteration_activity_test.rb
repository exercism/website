require 'test_helper'

class User::Activities::SubmittedIterationActivityTest < ActiveSupport::TestCase
  test "keys" do
    user = create :user
    exercise = create :concept_exercise
    solution = create(:concept_solution, user:, exercise:)
    iteration = create(:iteration, solution:)

    activity = User::Activities::SubmittedIterationActivity.create!(
      user:,
      track: exercise.track,
      solution:,
      params: {
        iteration:
      }
    )
    assert_equal "#{user.id}|submitted_iteration|Iteration##{iteration.id}",
      activity.uniqueness_key
  end

  test "rendering_data is valid" do
    freeze_time do
      user = create :user
      exercise = create :concept_exercise
      solution = create(:concept_solution, user:, exercise:)
      iteration = create :iteration, solution:, created_at: Time.current - 1.week, idx: 3

      activity = User::Activities::SubmittedIterationActivity.create!(
        user:,
        track: exercise.track,
        solution:,
        params: {
          iteration:
        }
      )

      assert_equal "/tracks/ruby/exercises/strings/iterations?idx=3", activity.rendering_data[:url]
      assert_equal "You submitted <strong>Iteration 3</strong>", activity.rendering_data[:text]
      assert_equal Time.current - 1.week, activity.rendering_data[:occurred_at]
    end
  end
end
