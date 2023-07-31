require 'test_helper'

class Submission::RepresentationTest < ActiveSupport::TestCase
  test "ops_success?" do
    refute create(:submission_representation, ops_status: 199).ops_success?
    assert create(:submission_representation, ops_status: 200).ops_success?
    refute create(:submission_representation, ops_status: 201).ops_success?
  end

  test "ops_errored?" do
    assert create(:submission_representation, ops_status: 199).ops_errored?
    refute create(:submission_representation, ops_status: 200).ops_errored?
    assert create(:submission_representation, ops_status: 201).ops_errored?
  end

  test "ops_errored? if no ast was set" do
    assert create(:submission_representation, ast: '', ast_digest: nil).ops_errored?
  end

  test "exercise_representation" do
    exercise = create :concept_exercise
    ast = "My AST"
    ast_digest = Submission::Representation.digest_ast(ast)

    representation = create(:submission_representation,
      submission: create(:submission, solution: create(:concept_solution, exercise:)),
      ast_digest:)

    # Wrong exercise
    create :exercise_representation,
      exercise: create(:concept_exercise),
      ast_digest: Submission::Representation.digest_ast(ast)

    assert_nil representation.reload.exercise_representation

    # Wrong ast
    create :exercise_representation,
      exercise:,
      ast_digest: "something"

    assert_nil representation.reload.exercise_representation

    # Correct everything!
    exercise_representation = create(:exercise_representation,
      exercise:,
      ast_digest:)

    assert_equal exercise_representation, representation.reload.exercise_representation
  end

  test "track: inferred from submission" do
    submission = create :submission
    representation = create(:submission_representation, submission:)

    assert_equal submission.track, representation.track
  end
end
