require "test_helper"

class Submission::Representation::TriggerRerunsForExerciseTest < ActiveSupport::TestCase
  test "runs for all iteration submissions" do
    exercise = create :practice_exercise
    submission = create :submission, solution: create(:practice_solution, exercise:, user: create(:user))
    create(:iteration, submission:)

    # This one doesn't have an iteration, so shouldn't be rerun
    create :submission, solution: create(:practice_solution, exercise:, user: create(:user))

    Submission::Representation::Init.expects(:call).with(submission, type: :exercise, git_sha: "HEAD", run_in_background: true)
    Submission::Representation::TriggerRerunsForExercise.(exercise)
  end
end
