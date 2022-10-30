require "test_helper"

class Exercise::Representation::CreateOrUpdateTest < ActiveSupport::TestCase
  test "creates representation" do
    exercise = create :practice_exercise
    submission = create :submission, exercise: exercise
    ast = 'def foo'
    ast_digest = 'hq471b'
    mapping = { 'a' => 'test' }
    last_submitted_at = Time.zone.now

    representation = Exercise::Representation::CreateOrUpdate.(submission, ast, ast_digest, mapping, last_submitted_at)

    assert_equal exercise, representation.exercise
    assert_equal submission, representation.source_submission
    assert_equal ast, representation.ast
    assert_equal ast_digest, representation.ast_digest
    assert_equal mapping, representation.mapping
    assert_equal last_submitted_at, representation.last_submitted_at
  end

  test "updates representation" do
    exercise = create :practice_exercise
    submission = create :submission, exercise: exercise
    ast = 'def foo'
    ast_digest = 'hq471b'
    mapping = { 'a' => 'test' }
    last_submitted_at = Time.zone.now

    representation = create(:exercise_representation, exercise:, source_submission: submission, ast:, ast_digest:, mapping:,
      last_submitted_at: Time.zone.now - 2.days)

    Exercise::Representation::CreateOrUpdate.(submission, ast, ast_digest, mapping, last_submitted_at)

    assert_equal last_submitted_at, representation.reload.last_submitted_at
  end

  test "calculates num_submissions with ast_digest being new" do
    ast = 'def foo'
    ast_digest = 'hq471b'
    mapping = { 'a' => 'test' }
    exercise = create :practice_exercise
    submission = create :submission, exercise: exercise
    create :submission_representation, ast_digest: ast_digest, submission: submission

    representation = Exercise::Representation::CreateOrUpdate.(submission, ast, ast_digest, mapping, Time.zone.now)

    perform_enqueued_jobs # Allow num_submissions to be calculated in the background

    assert_equal 1, representation.reload.num_submissions
  end

  test "calculates num_submissions with ast_digest already being used" do
    ast = 'def foo'
    ast_digest = 'hq471b'
    mapping = { 'a' => 'test' }
    exercise = create :practice_exercise
    submission = create :submission, exercise: exercise
    create :submission_representation, ast_digest: ast_digest, submission: submission
    create :submission_representation, ast_digest: ast_digest, submission: create(:submission, exercise:)
    create :submission_representation, ast_digest: ast_digest, submission: create(:submission, exercise:)

    representation = Exercise::Representation::CreateOrUpdate.(submission, ast, ast_digest, mapping, Time.zone.now)

    perform_enqueued_jobs # Allow num_submissions to be calculated in the background

    assert_equal 3, representation.reload.num_submissions
  end

  test "idempotent" do
    submission = create :submission
    last_submitted_at = Time.zone.now

    assert_idempotent_command do
      Exercise::Representation::CreateOrUpdate.(submission, 'def foo', 'hq471b', { 'a' => 'test' }, last_submitted_at)
    end
  end

  test "feedback is copied for same submission" do
    submission = create :submission
    Exercise::Representation::CreateOrUpdate.(submission, 'old', 'old', {}, Time.current)

    # Add feedback to that representation
    old_representation = Exercise::Representation.first
    Exercise::Representation::SubmitFeedback.(create(:user), old_representation, "fooobar", :essential)

    # Now generate a new reprentation
    Exercise::Representation::CreateOrUpdate.(submission, 'new', 'new', {}, Time.current)
    new_representation = Exercise::Representation.last

    refute_equal old_representation, new_representation # Sanity

    # Assert that the feedback has been copied
    assert_equal old_representation.feedback_author, new_representation.feedback_author
    assert_equal old_representation.feedback_markdown, new_representation.feedback_markdown
    assert_equal old_representation.feedback_type, new_representation.feedback_type
  end

  test "feedback is copied from most recent submission" do
    submission = create :submission
    create :exercise_representation, :with_feedback, exercise: submission.exercise, source_submission: submission,
      feedback_markdown: "ancient"
    old_representation = create :exercise_representation, :with_feedback, exercise: submission.exercise,
      source_submission: submission, feedback_markdown: "old"

    # Now generate a new reprentation
    Exercise::Representation::CreateOrUpdate.(submission, 'new', 'new', {}, Time.current)
    new_representation = Exercise::Representation.last

    # Sanity
    assert old_representation.feedback_markdown
    refute_equal old_representation, new_representation

    # Assert that the feedback has been copied from the newer reprsentation
    assert_equal old_representation.feedback_markdown, new_representation.feedback_markdown
  end

  test "feedback is not copied for different submission" do
    Exercise::Representation::CreateOrUpdate.(create(:submission), 'old', 'old', {}, Time.current)

    # Add feedback to that representation
    old_representation = Exercise::Representation.first
    Exercise::Representation::SubmitFeedback.(create(:user), old_representation, "fooobar", :essential)

    # Now generate a new reprentation
    Exercise::Representation::CreateOrUpdate.(create(:submission), 'new', 'new', {}, Time.current)
    new_representation = Exercise::Representation.last

    refute_equal old_representation, new_representation # Sanity

    # Assert that the feedback has been copied
    assert_nil new_representation.feedback_author
    assert_nil new_representation.feedback_markdown
    assert_nil new_representation.feedback_type
  end
end
