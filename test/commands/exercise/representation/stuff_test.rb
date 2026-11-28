require "test_helper"

class Exercise::Representation::StuffTest < ActiveSupport::TestCase
  test "submissions hitting separate base submission get the right feedback" do
    exercise = create :practice_exercise
    old_feedback = "Some something old"
    new_feedback = "Be more new"

    # Set up the base submission.
    # This is the one the mentor reviews and gives feedback to.
    # It has two representations (an old one and a newer one)
    base_submission = create :submission, solution: create(:practice_solution, exercise:)

    old_representation = create(:exercise_representation, :with_feedback, feedback_markdown: old_feedback,
      source_submission: base_submission, exercise:)
    new_representation = create(:exercise_representation, :with_feedback, feedback_markdown: new_feedback,
      source_submission: base_submission, exercise:)

    create :submission_representation, submission: base_submission, ast_digest: old_representation.ast_digest
    create :submission_representation, submission: base_submission, ast_digest: new_representation.ast_digest

    # Create one old submission (for the old representations)
    # and one new one (with the new representation)
    older_submission = create :submission, solution: create(:practice_solution, exercise:)
    create :submission_representation, submission: older_submission, ast_digest: old_representation.ast_digest

    newer_submission = create :submission, solution: create(:practice_solution, exercise:)
    create :submission_representation, submission: newer_submission, ast_digest: new_representation.ast_digest

    # Check they all get the correct reprsentation
    assert_equal new_representation, base_submission.exercise_representation
    assert_equal old_representation, older_submission.exercise_representation
    assert_equal new_representation, newer_submission.exercise_representation
  end

  test "if a new representation replaces an existing one, copy the comments" do
    # Create a submission  and generate a representation for it
    submission = create :submission
    create(:submission_file, submission:)
    stub_inspector!(representation: "ast 1")
    Submission::Representation::Generate.(submission, submission.git_sha)

    # Add feedback to that representation
    old_representation = Exercise::Representation.first
    Exercise::Representation::SubmitFeedback.(create(:user), old_representation, "fooobar", :essential)

    # Now generate a new reprentation
    stub_inspector!(representation: "ast 2")
    Submission::Representation::Generate.(submission, submission.git_sha)
    new_representation = Exercise::Representation.last

    refute_equal old_representation, new_representation # Sanity

    # Assert that the feedback has been copied
    assert_equal old_representation.feedback_author, new_representation.feedback_author
    assert_equal old_representation.feedback_markdown, new_representation.feedback_markdown
    assert_equal old_representation.feedback_type, new_representation.feedback_type
  end

  test "when a representater is updated, re-run all exercises that have been given feedback 30mins later" do
    # TODO...
  end
end
