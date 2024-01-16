require 'test_helper'

class Submission::Representation::CreateTest < ActiveSupport::TestCase
  test "creates submission representation record" do
    submission = create :submission
    job_id = SecureRandom.hex
    ops_status = 200
    ast = "here(lives(an(ast)))"
    ast_digest = Submission::Representation.digest_ast(ast)
    exercise_version = 123

    representation = Submission::Representation::Create.(submission, job_id, ops_status, ast_digest, exercise_version)

    assert_equal job_id, representation.tooling_job_id
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

    representation_1 = Submission::Representation::Create.(submission, 1, ops_status, ast_digest, exercise_version)
    representation_2 = Submission::Representation::Create.(submission, 2, ops_status, ast_digest, exercise_version)

    assert_equal representation_1, representation_2
  end

  test "updates mentor of submission representation" do
    mentor = create :user
    iteration = create :iteration
    submission = iteration.submission
    discussion = create :mentor_discussion, mentor:, solution: iteration.solution
    create :mentor_discussion_post, discussion:, iteration:, author: mentor

    representation = Submission::Representation::Create.(submission, 1, 200, "the_digest", 1)
    perform_enqueued_jobs

    assert_equal mentor, representation.reload.mentored_by
  end

  test "updates published exercise representation for solution" do
    iteration = create :iteration
    submission = iteration.submission

    Solution::UpdatePublishedExerciseRepresentation.expects(:defer).with(submission.solution, wait: 10)

    Submission::Representation::Create.(submission, 1, 200, "the_digest", 1)
  end
end
