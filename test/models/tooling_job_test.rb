require 'test_helper'

class ToolingJobTest < ActiveSupport::TestCase
  test "retrieves metadata from s3" do
    job_id = SecureRandom.uuid
    stdout = "Some output"
    stderr = "Some errors"

    bucket = Exercism.config.aws_tooling_jobs_bucket
    folder = "#{Exercism.env}/#{job_id}"
    upload_to_s3(bucket, "#{folder}/stdout", stdout)
    upload_to_s3(bucket, "#{folder}/stderr", stderr)

    job = ToolingJob.new(id: job_id)
    assert_equal stdout, job.stdout
    assert_equal stderr, job.stderr
  end
end
