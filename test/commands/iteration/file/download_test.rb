require 'test_helper'

class Iteration::File::DownloadTest < ActiveSupport::TestCase
  test "downloads correctly" do
    iteration_uuid = SecureRandom.uuid

    filename = "subdir/original_file_1.rb"
    file_contents = "file 1 contents"
    key = Iteration::File::GenerateS3Key.(iteration_uuid, filename)

    s3_object = mock
    s3_object.expects(body: mock(read: file_contents))
    s3_client = mock
    s3_client.expects(:get_object).with(
      bucket: Exercism.config.aws_iterations_bucket,
      key: key
    ).returns(s3_object)
    ExercismConfig::SetupS3Client.stubs(call: s3_client)

    assert_equal file_contents,
                 Iteration::File::Download.(iteration_uuid, filename)
  end
end
