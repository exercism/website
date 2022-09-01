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
end
