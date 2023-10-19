require 'test_helper'

class ToolingJob::ProcessTest < ActiveSupport::TestCase
  test "proxies to test run" do
    job = create_test_runner_job!(create(:submission))

    Submission::TestRun::Process.expects(:call).with(job)

    ToolingJob::Process.(job.id)
  end

  test "guards duplicate test run processing" do
    job = create_test_runner_job!(create(:submission))

    # Simulate a race condition by retreiving both first
    # then running the first command then the second sequentially
    cmd_1 = ToolingJob::Process.new(job.id)
    cmd_1.send(:job)
    cmd_2 = ToolingJob::Process.new(job.id)
    cmd_2.send(:job)
    cmd_1.()

    Submission::TestRun::Process.expects(:call).with(job).never
    cmd_2.()
  end

  test "proxies to representer" do
    job = create_representer_job!(create(:submission))

    Submission::Representation::Process.expects(:call).with(job)

    ToolingJob::Process.(job.id)
  end

  test "proxies to analyzer" do
    job = create_analyzer_job!(create(:submission))

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
