require "test_helper"

class SPI::ToolingJobsControllerTest < ActionDispatch::IntegrationTest
  test "update proxies to command" do
    id = SecureRandom.uuid
    ToolingJob::Process.expects(:call).with(id)

    patch spi_tooling_job_url(id)
  end
end
