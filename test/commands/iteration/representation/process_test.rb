require 'test_helper'

class Iteration::Representation::ProcessTest < ActiveSupport::TestCase

  test "creates iteration representation record" do
    iteration = create :iteration
    ops_status = 200
    ops_message = "some ops message"
    ast = "here(lives(an(ast)))"

    Iteration::Representation::Process.(iteration.uuid, ops_status, ops_message, ast)

    assert_equal 1, iteration.reload.representations.size
    representation = iteration.reload.representations.first

    assert_equal ops_status, representation.ops_status
    assert_equal ops_message, representation.ops_message
    assert_equal ast, representation.ast
  end

  test "creates exercise representation" do
    ast = "my ast"
    ast_digest = Digest::SHA1.hexdigest(ast)
    iteration = create :iteration

    Iteration::Representation::Process.(iteration.uuid, 200, "", ast)

    assert_equal 1, Exercise::Representation.count
    representation = Exercise::Representation.first

    assert_equal iteration.exercise, representation.exercise
    assert_equal ast, representation.ast
    assert_equal ast_digest, representation.ast_digest

    # TODO: Check the exercise version properly here. 
    # Add it to the git repo and check it retrieves correctly
    assert_equal 15, representation.exercise_version
  end

  test "test exercise representations are reused" do
    solution = create :concept_solution
    iteration_1 = create :iteration, solution: solution
    iteration_2 = create :iteration, solution: solution
    iteration_3 = create :iteration, solution: solution

    Iteration::Representation::Process.(iteration_1.uuid, 200, "", "ast 1")
    Iteration::Representation::Process.(iteration_2.uuid, 200, "", "ast 1")

    assert_equal 2, Iteration::Representation.count
    assert_equal 1, Exercise::Representation.count

    Iteration::Representation::Process.(iteration_3.uuid, 200, "", "ast 2")
    assert_equal 3, Iteration::Representation.count
    assert_equal 2, Exercise::Representation.count
  end

  test "handle ops error" do
    iteration = create :iteration
    Iteration::Representation::Process.(iteration.uuid, 500, "", "ast")

    assert iteration.reload.representation_exceptioned?
  end

  test "handle approval" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    exercise_representation = create :exercise_representation, 
      exercise: exercise,
      exercise_version: 15,
      ast_digest: Iteration::Representation.digest_ast(ast),
      action: :approve

    iteration = create :iteration, exercise: exercise
    Iteration::Representation::Process.(iteration.uuid, 200, "", ast)

    assert iteration.reload.representation_approved?
  end

  test "handle disapproved" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    exercise_representation = create :exercise_representation, 
      exercise: exercise,
      exercise_version: 15,
      ast_digest: Iteration::Representation.digest_ast(ast),
      action: :disapprove

    iteration = create :iteration, exercise: exercise
    Iteration::Representation::Process.(iteration.uuid, 200, "", ast)

    assert iteration.reload.representation_disapproved?
  end

  test "handle disapproved with comments" do
    mentor = create :user
    feedback = "foobar"

    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    exercise_representation = create :exercise_representation, 
      exercise: exercise,
      exercise_version: 15,
      ast_digest: Iteration::Representation.digest_ast(ast),
      action: :disapprove,
      feedback_author: mentor,
      feedback_markdown: feedback

    iteration = create :iteration, exercise: exercise
    Iteration::Representation::Process.(iteration.uuid, 200, "", ast)

    assert iteration.reload.representation_disapproved?
    assert_equal 1, iteration.reload.discussion_posts.size
    assert_equal mentor, iteration.reload.discussion_posts.first.user
    assert_equal feedback, iteration.reload.discussion_posts.first.content_markdown
  end

  test "handle inconclusive" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    exercise_representation = create :exercise_representation, 
      exercise: exercise,
      exercise_version: 15,
      ast_digest: Iteration::Representation.digest_ast(ast),
      action: :pending

    iteration = create :iteration, exercise: exercise
    Iteration::Representation::Process.(iteration.uuid, 200, "", ast)

    assert iteration.reload.representation_inconclusive?
  end
end
