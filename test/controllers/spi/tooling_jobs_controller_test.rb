require "test_helper"

class SPI::ToolingJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! URI(Exercism.config.spi_url).host
  end

  test "update proxies to command" do
    id = SecureRandom.uuid
    ToolingJob::Process.expects(:call).with(id)

    patch spi_tooling_job_path(id)
  end
end
