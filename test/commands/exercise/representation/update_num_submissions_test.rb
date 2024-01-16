require "test_helper"

class Exercise::Representation::UpdateNumSubmissionsTest < ActiveSupport::TestCase
  test "recalculates num_submissions" do
    exercise = create :practice_exercise
    submission = create :submission, solution: (create :practice_solution, exercise:), tests_status: :passed
    representation = create :exercise_representation, ast_digest: 'foo', exercise:, source_submission: submission
    create(:submission_representation, ast_digest: 'foo', submission:)

    # Other submissions with same digest
    create :submission_representation, ast_digest: 'foo',
      submission: create(:submission, solution: (create :practice_solution, exercise:), tests_status: :passed)
    create :submission_representation, ast_digest: 'foo',
      submission: create(:submission, solution: (create :practice_solution, exercise:), tests_status: :passed)

    # Other submission with different digest
    create :submission_representation, ast_digest: 'bar',
      submission: create(:submission, solution: (create :practice_solution, exercise:), tests_status: :passed)

    # Sanity check
    assert_equal 1, representation.num_submissions

    Exercise::Representation::UpdateNumSubmissions.(representation)

    assert_equal 3, representation.reload.num_submissions
  end

  test "num_submissions is unique per submission" do
    exercise = create :practice_exercise
    submission = create :submission, solution: (create :practice_solution, exercise:), tests_status: :passed
    representation = create :exercise_representation, ast_digest: 'foo', exercise:, source_submission: submission

    # Sanity check
    assert_equal 1, representation.num_submissions

    create(:submission_representation, ast_digest: representation.ast_digest, submission:)
    create(:submission_representation, ast_digest: representation.ast_digest, submission:)
    create(:submission_representation, ast_digest: representation.ast_digest, submission:)

    # Sanity check
    assert_equal 1, representation.num_submissions

    Exercise::Representation::UpdateNumSubmissions.(representation)

    assert_equal 1, representation.reload.num_submissions
  end

  test "only considers passing submissions" do
    exercise = create :practice_exercise
    submission = create :submission, solution: (create :practice_solution, exercise:), tests_status: :passed
    representation = create :exercise_representation, ast_digest: 'foo', exercise:, source_submission: submission
    create(:submission_representation, ast_digest: 'foo', submission:)

    # Other submissions with same digest
    create :submission_representation, ast_digest: 'foo',
      submission: create(:submission, solution: (create :practice_solution, exercise:), tests_status: :failed)
    create :submission_representation, ast_digest: 'foo',
      submission: create(:submission, solution: (create :practice_solution, exercise:), tests_status: :queued)

    # Sanity check
    representation.update_column(:num_submissions, 0)
    assert_equal 0, representation.num_submissions

    Exercise::Representation::UpdateNumSubmissions.(representation)

    assert_equal 1, representation.reload.num_submissions
  end
end
