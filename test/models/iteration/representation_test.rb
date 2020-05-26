require 'test_helper'

class Iteration::RepresentationTest < ActiveSupport::TestCase
  test "ops_success?" do
    refute create(:iteration_representation, ops_status: 199).ops_success?
    assert create(:iteration_representation, ops_status: 200).ops_success?
    refute create(:iteration_representation, ops_status: 201).ops_success?
  end

  test "ops_errored?" do
    assert create(:iteration_representation, ops_status: 199).ops_errored?
    refute create(:iteration_representation, ops_status: 200).ops_errored?
    assert create(:iteration_representation, ops_status: 201).ops_errored?
  end

  test "exercise_representation" do
    exercise = create :concept_exercise
    ast = "My AST"
    ast_digest = Iteration::Representation.digest_ast(ast)

    representation = create :iteration_representation, 
      iteration: create(:iteration, exercise: exercise),
      ast: ast

    # Wrong exercise version
    exercise_representation = create :exercise_representation, 
      exercise: exercise,
      exercise_version: 2,
      ast_digest: ast_digest
    assert_raises do
      representation.exercise_representation
    end

    # Wrong exercise
    exercise_representation = create :exercise_representation, 
      exercise: create(:concept_exercise),
      exercise_version: 15,
      ast_digest: Iteration::Representation.digest_ast(ast)
    assert_raises do
      representation.exercise_representation
    end

    # Wrong ast
    exercise_representation = create :exercise_representation, 
      exercise: exercise,
      exercise_version: 15,
      ast_digest: "something"
    assert_raises do
      representation.exercise_representation
    end

    # Correct everything!
    exercise_representation = create :exercise_representation, 
      exercise: exercise,
      exercise_version: 15,
      ast_digest: ast_digest
    assert_equal exercise_representation, representation.exercise_representation
  end
end
