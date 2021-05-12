require 'test_helper'

class ToolingJob::ProcessTest < ActiveSupport::TestCase
  test "proxies to test run" do
    submission = create :submission
    execution_status = "job-status"
    results = { 'some' => 'result' }
    job_id = create_test_runner_job!(
      submission,
      execution_status: execution_status,
      results: results
    )

    Submission::TestRun::Process.expects(:call).with(Exercism::ToolingJob.find(job_id))

    ToolingJob::Process.(job_id)
  end

  test "proxies to representer" do
    submission = create :submission
    execution_status = "job-status"
    job_id = create_representer_job!(
      submission,
      execution_status: execution_status,
      ast: nil,
      mapping: nil
    )

    Submission::Representation::Process.expects(:call).with(Exercism::ToolingJob.find(job_id))

    ToolingJob::Process.(job_id)
  end

  test "proxies to analyzer" do
    submission = create :submission
    execution_status = "job-status"
    job_id = create_analyzer_job!(
      submission,
      execution_status: execution_status,
      data: nil
    )

    Submission::Analysis::Process.expects(:call).with(Exercism::ToolingJob.find(job_id))

    ToolingJob::Process.(job_id)
  end

  test "set status to processed" do
    submission = create :submission

    job_id = create_analyzer_job!(
      submission,
      execution_status: "job-status",
      data: nil
    )

    ToolingJob::Process.(job_id)

    redis = Exercism.redis_tooling_client
    assert_nil redis.lindex(Exercism::ToolingJob.key_for_executed, 0)
    assert_equal job_id, redis.lindex(Exercism::ToolingJob.key_for_processed, 0)
  end
end
