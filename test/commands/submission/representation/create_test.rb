require 'test_helper'

class Submission::Representation::CreateTest < ActiveSupport::TestCase
  test "creates submission representation record" do
    submission = create :submission
    ops_status = 200
    ast = "here(lives(an(ast)))"
    ast_digest = Submission::Representation.digest_ast(ast)

    job = create_representer_job!(submission, execution_status: ops_status, ast:)
    representation = Submission::Representation::Create.(submission, job, ast_digest)

    assert_equal job.id, representation.tooling_job_id
    assert_equal ops_status, representation.ops_status
    assert_equal ast_digest, representation.ast_digest
  end
end
