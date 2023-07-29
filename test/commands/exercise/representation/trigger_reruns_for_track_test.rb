require "test_helper"

class Exercise::Representation::TriggerRerunsForTrackTest < ActiveSupport::TestCase
  test "runs for correct submissions" do
    git_sha = SecureRandom.uuid
    ast_digest = SecureRandom.uuid

    track = create :track
    submission_1 = create :submission, solution: create(:practice_solution, git_sha:, track:)
    submission_2 = create :submission, solution: create(:practice_solution, git_sha: SecureRandom.uuid, track:)
    create :submission_representation, ast_digest:, submission: submission_1
    create :submission_representation, ast_digest:, submission: submission_2
    create(:exercise_representation, :with_feedback, ast_digest:, source_submission: submission_1, exercise: submission_1.exercise)
    create(:exercise_representation, ast_digest:, source_submission: submission_2, exercise: submission_2.exercise)

    # Sanity
    assert_equal submission_1.reload.track, submission_2.reload.track

    Submission::Representation::Init.expects(:call).with(submission_1, type: :exercise, git_sha: "HEAD", run_in_background: true)
    Exercise::Representation::TriggerRerunsForTrack.(track)
  end
end
