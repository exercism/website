require 'test_helper'

class Submission::Representation::CreateTest < ActiveSupport::TestCase
  test "creates submission representation record" do
    submission = create :submission
    ops_status = 200
    ast = "here(lives(an(ast)))"
    ast_digest = Submission::Representation.digest_ast(ast)
    exercise_version = 123

    job = create_representer_job!(submission, execution_status: ops_status, ast:)
    representation = Submission::Representation::Create.(submission, job, ast_digest, exercise_version)

    assert_equal job.id, representation.tooling_job_id
    assert_equal ops_status, representation.ops_status
    assert_equal ast_digest, representation.ast_digest
    assert_equal exercise_version, representation.exercise_representer_version
  end

  test "reuses existing record for the same key fields" do
    submission = create :submission
    ops_status = 200
    ast = "here(lives(an(ast)))"
    ast_digest = Submission::Representation.digest_ast(ast)
    exercise_version = 123

    job_1 = create_representer_job!(submission, execution_status: ops_status, ast:)
    representation_1 = Submission::Representation::Create.(submission, job_1, ast_digest, exercise_version)

    job_2 = create_representer_job!(submission, execution_status: ops_status, ast:)
    representation_2 = Submission::Representation::Create.(submission, job_2, ast_digest, exercise_version)

    assert_equal representation_1, representation_2
  end

  test "updates mentor of submission representation" do
    mentor = create :user
    iteration = create :iteration
    submission = iteration.submission
    discussion = create :mentor_discussion, mentor:, solution: iteration.solution
    create :mentor_discussion_post, discussion:, iteration:, author: mentor

    job = create_representer_job!(submission, execution_status: 200, ast: "here(lives(an(ast)))")
    representation = Submission::Representation::Create.(submission, job, "the_digest", 1)
    perform_enqueued_jobs

    assert_equal mentor, representation.reload.mentored_by
  end
end
