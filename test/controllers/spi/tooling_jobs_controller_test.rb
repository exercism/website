require "test_helper"

class SPI::ToolingJobsControllerTest < ActionDispatch::IntegrationTest
  test "update proxies to command for test runner" do
    job = create_test_runner_job!(create(:submission))

    Submission::TestRun::Process.expects(:call).with(job)

    patch spi_tooling_job_url(job.id)
  end

  test "update proxies to command for representer" do
    job = create_representer_job!(create(:submission))

    # Shouldn't call command immediately
    patch spi_tooling_job_url(job.id)

    # But should via sidekiq
    Submission::Representation::Process.expects(:call).with(job)
    perform_enqueued_jobs
  end
end
