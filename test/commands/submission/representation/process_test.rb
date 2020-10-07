require 'test_helper'

class Submission::Representation::ProcessTest < ActiveSupport::TestCase
  test "creates submission representation record" do
    submission = create :submission
    ops_status = 200
    ops_message = "some ops message"
    ast = "here(lives(an(ast)))"

    Submission::Representation::Process.(submission.uuid, ops_status, ops_message, ast, {})

    assert_equal 1, submission.reload.representations.size
    representation = submission.reload.representations.first

    assert_equal ops_status, representation.ops_status
    assert_equal ops_message, representation.ops_message
    assert_equal ast, representation.ast
  end

  test "creates exercise representation" do
    ast = "my ast"
    ast_digest = Digest::SHA1.hexdigest(ast)
    submission = create :submission
    mapping = { 'foo' => 'bar' }

    Submission::Representation::Process.(submission.uuid, 200, "", ast, mapping)

    assert_equal 1, Exercise::Representation.count
    representation = Exercise::Representation.first

    assert_equal submission.exercise, representation.exercise
    assert_equal ast, representation.ast
    assert_equal ast_digest, representation.ast_digest
    assert_equal mapping, representation.mapping

    # TODO: Check the exercise version properly here.
    # Add it to the git repo and check it retrieves correctly
    assert_equal 15, representation.exercise_version
  end

  test "test exercise representations are reused" do
    solution = create :concept_solution
    submission_1 = create :submission, solution: solution
    submission_2 = create :submission, solution: solution
    submission_3 = create :submission, solution: solution

    Submission::Representation::Process.(submission_1.uuid, 200, "", "ast 1", {})
    Submission::Representation::Process.(submission_2.uuid, 200, "", "ast 1", {})

    assert_equal 2, Submission::Representation.count
    assert_equal 1, Exercise::Representation.count

    Submission::Representation::Process.(submission_3.uuid, 200, "", "ast 2", {})
    assert_equal 3, Submission::Representation.count
    assert_equal 2, Exercise::Representation.count
  end

  test "handle ops error" do
    submission = create :submission
    Submission::Representation::Process.(submission.uuid, 500, "", "ast", {})

    assert submission.reload.representation_exceptioned?
  end

  test "handle approval" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise: exercise,
      exercise_version: 15,
      ast_digest: Submission::Representation.digest_ast(ast),
      action: :approve

    submission = create :submission, exercise: exercise
    Submission::Representation::Process.(submission.uuid, 200, "", ast, {})

    assert submission.reload.representation_approved?
  end

  test "handle disapproved" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise: exercise,
      exercise_version: 15,
      ast_digest: Submission::Representation.digest_ast(ast),
      action: :disapprove

    submission = create :submission, exercise: exercise
    Submission::Representation::Process.(submission.uuid, 200, "", ast, {})

    assert submission.reload.representation_disapproved?
  end

  test "handle disapproved with comments" do
    mentor = create :user
    feedback = "foobar"

    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise: exercise,
      exercise_version: 15,
      ast_digest: Submission::Representation.digest_ast(ast),
      action: :disapprove,
      feedback_author: mentor,
      feedback_markdown: feedback

    submission = create :submission, exercise: exercise
    Submission::Representation::Process.(submission.uuid, 200, "", ast, {})

    assert submission.reload.representation_disapproved?
    assert_equal 1, submission.reload.discussion_posts.size
    assert_equal mentor, submission.reload.discussion_posts.first.user
    assert_equal feedback, submission.reload.discussion_posts.first.content_markdown
  end

  test "handle inconclusive" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise: exercise,
      exercise_version: 15,
      ast_digest: Submission::Representation.digest_ast(ast),
      action: :pending

    submission = create :submission, exercise: exercise
    Submission::Representation::Process.(submission.uuid, 200, "", ast, {})

    assert submission.reload.representation_inconclusive?
  end

  test "broadcast" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise: exercise,
      exercise_version: 15,
      ast_digest: Submission::Representation.digest_ast(ast),
      action: :approve

    submission = create :submission, exercise: exercise

    SubmissionChannel.expects(:broadcast!).with(submission)
    SubmissionsChannel.expects(:broadcast!).with(submission.solution)

    Submission::Representation::Process.(submission.uuid, 200, "", ast, {})
  end
end
