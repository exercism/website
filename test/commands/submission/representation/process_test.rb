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
    submission = create :submission, tests_status: :passed
    mapping = { 'foo' => 'bar' }

    job = create_representer_job!(submission, execution_status: 200, ast:, mapping:)
    Submission::Representation::Process.(job)

    perform_enqueued_jobs

    assert_equal 1, Exercise::Representation.count
    representation = Exercise::Representation.first

    assert_equal submission.exercise, representation.exercise
    assert_equal ast, representation.ast
    assert_equal ast_digest, representation.ast_digest
    assert_equal mapping, representation.mapping
    assert_equal 1, representation.num_submissions
    assert_equal submission.submission_representation.created_at, representation.last_submitted_at
  end

  test "representer_version" do
    submission = create :submission
    ast = "here(lives(an(ast)))"
    metadata = { version: 3 }

    job = create_representer_job!(submission, execution_status: 200, ast:, metadata:)
    Submission::Representation::Process.(job)

    representation = Exercise::Representation.first
    assert_equal 3, representation.representer_version
  end

  test "representer_version for job without metadata" do
    submission = create :submission
    ast = "here(lives(an(ast)))"
    metadata = nil

    job = create_representer_job!(submission, execution_status: 200, ast:, metadata:)
    Submission::Representation::Process.(job)

    representation = Exercise::Representation.first
    assert_equal 1, representation.representer_version
  end

  test "test exercise representations are reused" do
    solution = create :concept_solution
    submission_1 = create(:submission, solution:)
    submission_2 = create(:submission, solution:)
    submission_3 = create(:submission, solution:)

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

    assert_equal submission_1.exercise_representation, submission_2.exercise_representation
    refute_equal submission_2.exercise_representation, submission_3.exercise_representation
  end

  test "handle ops error" do
    submission = create :submission

    Bugsnag.expects(:notify).never

    job = create_representer_job!(submission, execution_status: 500, ast: nil)
    Submission::Representation::Process.(job)

    assert submission.reload.representation_exceptioned?
  end

  test "handle invalid ast" do
    exercise = create :concept_exercise
    submission = create(:submission, exercise:)

    job = create_representer_job!(submission, execution_status: 200, ast: "")
    Submission::Representation::Process.(job)

    assert submission.reload.representation_exceptioned?
  end

  test "handle generated" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise:,
      ast_digest: Submission::Representation.digest_ast(ast)

    submission = create(:submission, exercise:)

    job = create_representer_job!(submission, execution_status: 200, ast:)
    Submission::Representation::Process.(job)

    assert submission.reload.representation_generated?
  end

  test "handle exceptions during processing" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise:,
      ast_digest: Submission::Representation.digest_ast(ast),
      feedback_author: create(:user),
      feedback_markdown: "foobar"

    submission = create(:submission, exercise:)

    job = create_representer_job!(submission, execution_status: 200, ast:)
    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Submission::Representation::ProcessResults.any_instance.expects(:handle_generated!).raises
    end

    # We have a guard to reraise in dev/test here, so
    # stimulate production for this step
    Rails.env.expects(:production?).returns(true)

    Submission::Representation::Process.(job)

    assert submission.reload.representation_exceptioned?
  end

  test "broadcast without iteration" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise:,
      ast_digest: Submission::Representation.digest_ast(ast)

    submission = create(:submission, exercise:)

    SubmissionChannel.expects(:broadcast!).with(submission)

    job = create_representer_job!(submission, execution_status: 200, ast:)
    Submission::Representation::Process.(job)
  end

  test "broadcast with iteration" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise:,
      ast_digest: Submission::Representation.digest_ast(ast)

    submission = create(:submission, exercise:)
    iteration = create(:iteration, submission:)

    IterationChannel.expects(:broadcast!).with(iteration)
    SubmissionChannel.expects(:broadcast!).with(submission)

    job = create_representer_job!(submission, execution_status: 200, ast:)
    Submission::Representation::Process.(job)
  end

  test "honours reason" do
    ast = "my ast"
    ast_digest = Submission::Representation.digest_ast(ast)
    submission = create :submission
    mapping = { 'foo' => 'bar' }
    reason = :update

    job = create_representer_job!(submission, execution_status: 200, ast:, mapping:, reason:)

    Submission::Representation::Create.expects(:call).never
    Exercise::Representation::CreateOrUpdate.expects(:call).with(
      submission,
      ast, ast_digest, mapping.symbolize_keys,
      1, 1, submission.created_at, "HEAD"
    )

    Submission::Representation::Process.(job)
  end

  test "exercise_version is 1 by default" do
    # No version is set for hamming here
    exercise = create :practice_exercise, slug: "hamming", git_sha: "87448759c3f447c0a20db660b278a628e299e602"
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)
    job = create_representer_job!(submission, execution_status: 200, ast: 'ast')
    Submission::Representation::Process.(job)

    representation = Exercise::Representation.last

    assert_equal 1, representation.exercise_version
  end

  test "exercise_version is set from the git_sha" do
    slug = "space-age"
    v1_sha = "8b874172f74acad07ca880c71814a85eb883e2d7"
    v2_sha = "9f9d8f5bdac4411d0497af0f393ae76f2ab33a97"
    exercise = create(:practice_exercise, slug:)
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)

    # First test with the v1_sha
    job = create_representer_job!(submission, execution_status: 200, ast: 'ast', git_sha: v1_sha)
    Submission::Representation::Process.(job)
    representation = Exercise::Representation.last
    assert_equal 1, representation.exercise_version

    # Then with the v2 sha
    job = create_representer_job!(submission, execution_status: 200, ast: 'ast', git_sha: v2_sha)
    Submission::Representation::Process.(job)
    representation = Exercise::Representation.last
    assert_equal 2, representation.exercise_version
  end

  test "gracefully handle representation.json not being there" do
    ops_status = 200
    ast = "my ast"
    ast_digest = Submission::Representation.digest_ast(ast)
    submission = create :submission
    mapping = { 'foo' => 'bar' }

    Bugsnag.expects(:notify).never

    job = create_representer_job!(submission, execution_status: ops_status, ast:, mapping:)

    execution_output = {
      "representation.txt" => ast,
      "mapping.json" => mapping.to_json
    }
    create_tooling_job!(
      submission,
      :representer,
      execution_status: 200,
      execution_output:,
      context: { reason: nil },
      source: {
        'exercise_git_sha' => submission.git_sha
      }
    )

    Submission::Representation::Process.(job)

    representation = submission.reload.submission_representation

    assert_equal job.id, representation.tooling_job_id
    assert_equal ops_status, representation.ops_status
    assert_equal ast_digest, representation.ast_digest
  end
end
