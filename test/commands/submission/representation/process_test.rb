require 'test_helper'

class Submission::Representation::ProcessTest < ActiveSupport::TestCase
  test "creates submission representation record" do
    submission = create :submission
    ops_status = 200
    ast = "here(lives(an(ast)))"
    ast_digest = Submission::Representation.digest_ast(ast)

    job = create_representer_job!(submission, execution_status: ops_status, ast:)
    Submission::Representation::Process.(job)

    representation = submission.reload.submission_representation

    assert_equal job.id, representation.tooling_job_id
    assert_equal ops_status, representation.ops_status
    assert_equal ast_digest, representation.ast_digest
  end

  test "creates exercise representation" do
    ast = "my ast"
    ast_digest = Submission::Representation.digest_ast(ast)
    submission = create :submission
    mapping = { 'foo' => 'bar' }

    job = create_representer_job!(submission, execution_status: 200, ast:, mapping:)
    Submission::Representation::Process.(job)

    assert_equal 1, Exercise::Representation.count
    representation = Exercise::Representation.first

    assert_equal submission.exercise, representation.exercise
    assert_equal ast, representation.ast
    assert_equal ast_digest, representation.ast_digest
    assert_equal mapping, representation.mapping
  end

  test "test exercise representations are reused" do
    solution = create :concept_solution
    submission_1 = create :submission, solution: solution
    submission_2 = create :submission, solution: solution
    submission_3 = create :submission, solution: solution

    job_1 = create_representer_job!(submission_1, execution_status: 200, ast: "ast 1")
    job_2 = create_representer_job!(submission_2, execution_status: 200, ast: "ast 1")

    Submission::Representation::Process.(job_1)
    Submission::Representation::Process.(job_2)

    assert_equal 2, Submission::Representation.count
    assert_equal 1, Exercise::Representation.count

    job_3 = create_representer_job!(submission_3, execution_status: 200, ast: "ast 2")
    Submission::Representation::Process.(job_3)
    assert_equal 3, Submission::Representation.count
    assert_equal 2, Exercise::Representation.count
  end

  test "handle ops error" do
    submission = create :submission

    job = create_representer_job!(submission, execution_status: 500, ast: nil)
    Submission::Representation::Process.(job)

    assert submission.reload.representation_exceptioned?
  end

  test "handle invalid ast" do
    exercise = create :concept_exercise
    submission = create :submission, exercise: exercise

    job = create_representer_job!(submission, execution_status: 200, ast: "")
    Submission::Representation::Process.(job)

    assert submission.reload.representation_exceptioned?
  end

  test "handle generated" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise: exercise,
      ast_digest: Submission::Representation.digest_ast(ast)

    submission = create :submission, exercise: exercise

    job = create_representer_job!(submission, execution_status: 200, ast:)
    Submission::Representation::Process.(job)

    assert submission.reload.representation_generated?
  end

  test "handle exceptions during processing" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise: exercise,
      ast_digest: Submission::Representation.digest_ast(ast),
      feedback_author: create(:user),
      feedback_markdown: "foobar"

    submission = create :submission, exercise: exercise

    job = create_representer_job!(submission, execution_status: 200, ast:)
    cmd = Submission::Representation::Process.new(job)
    cmd.expects(:handle_generated!).raises
    cmd.()

    assert submission.reload.representation_exceptioned?
  end

  test "broadcast without iteration" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise: exercise,
      ast_digest: Submission::Representation.digest_ast(ast)

    submission = create :submission, exercise: exercise

    SubmissionChannel.expects(:broadcast!).with(submission)

    job = create_representer_job!(submission, execution_status: 200, ast:)
    Submission::Representation::Process.(job)
  end

  test "broadcast with iteration" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise: exercise,
      ast_digest: Submission::Representation.digest_ast(ast)

    submission = create :submission, exercise: exercise
    iteration = create :iteration, submission: submission

    IterationChannel.expects(:broadcast!).with(iteration)
    SubmissionChannel.expects(:broadcast!).with(submission)

    job = create_representer_job!(submission, execution_status: 200, ast:)
    Submission::Representation::Process.(job)
  end
end
