require "test_helper"

class Exercise::Representation::TriggerRerunsTest < ActiveSupport::TestCase
  test "runs for correct submissions" do
    git_sha = SecureRandom.uuid
    ast_digest = SecureRandom.uuid

    good_submission = create :submission, solution: create(:practice_solution, git_sha:)
    bad_submission = create :submission, solution: create(:practice_solution, git_sha: SecureRandom.uuid)
    exercise_representation = create(:exercise_representation, ast_digest:, exercise: good_submission.exercise)
    create :submission_representation, ast_digest:, submission: good_submission
    create :submission_representation, ast_digest:, submission: bad_submission

    Submission::Representation::Init.expects(:call).with(good_submission, run_in_background: true)
    Exercise::Representation::TriggerReruns.(exercise_representation, git_sha)
  end
end
