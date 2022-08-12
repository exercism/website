require "test_helper"

class Exercise::Representation::UpdateNumSubmissionsTest < ActiveSupport::TestCase
  test "recalculates num_submissions" do
    exercise_1 = create :practice_exercise
    exercise_2 = create :practice_exercise

    submission = create :submission, solution: (create :practice_solution, exercise: exercise_1)

    representation = create :exercise_representation, ast_digest: 'foo', exercise: exercise_1, source_submission: submission

    create :submission_representation, ast_digest: 'foo', submission: submission

    # Other submissions for same exercise with same digest
    create :submission_representation, ast_digest: 'foo',
      submission: create(:submission, solution: (create :practice_solution, exercise: exercise_1))
    create :submission_representation, ast_digest: 'foo',
      submission: create(:submission, solution: (create :practice_solution, exercise: exercise_1))

    # Other submission for same exercise with different digest
    create :submission_representation, ast_digest: 'bar',
      submission: create(:submission, solution: (create :practice_solution, exercise: exercise_1))

    # Other submission for different exercise with same digest (very unlikely)
    create :submission_representation, ast_digest: 'foo',
      submission: create(:submission, solution: (create :practice_solution, exercise: exercise_2))

    # Sanity check
    assert_equal 0, representation.num_submissions

    Exercise::Representation::UpdateNumSubmissions.(representation)

    assert_equal 3, representation.reload.num_submissions
  end
end
