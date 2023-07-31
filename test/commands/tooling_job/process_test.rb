require 'test_helper'

class ToolingJob::ProcessTest < ActiveSupport::TestCase
  test "proxies to test run" do
    submission = create :submission
    execution_status = "job-status"
    results = { 'some' => 'result' }
    job = create_test_runner_job!(
      submission,
      execution_status:,
      results:
    )

    Submission::TestRun::Process.expects(:call).with(job)

    ToolingJob::Process.(job.id)
  end

  test "proxies to representer" do
    submission = create :submission
    execution_status = "job-status"
    job = create_representer_job!(
      submission,
      execution_status:,
      ast: nil,
      mapping: nil
    )

    Submission::Representation::Process.expects(:call).with(job)

    ToolingJob::Process.(job.id)
  end

  test "proxies to analyzer" do
    submission = create :submission
    execution_status = "job-status"
    job = create_analyzer_job!(
      submission,
      execution_status:,
      data: nil
    )

    Submission::Analysis::Process.expects(:call).with(job)

    ToolingJob::Process.(job.id)
  end

  test "set status to processed" do
    submission = create :submission

    job = create_analyzer_job!(
      submission,
      execution_status: "job-status",
      data: nil
    )

    ToolingJob::Process.(job.id)

    redis = Exercism.redis_tooling_client
    assert_nil redis.lindex(Exercism::ToolingJob.key_for_executed, 0)
  end
end
