require 'test_helper'

class Iteration::UploadForStorageTest < ActiveSupport::TestCase
  test "uploads correct files" do
    iteration_uuid = SecureRandom.uuid

    file_1_name = "subdir/original_file_1.rb"
    file_2_name = "original_file_2.rb"
    file_3_name = "original_file_3.rb"

    file_1_contents = "file 1 contents"
    file_2_contents = "file 2 contents"
    file_3_contents = "file 3 contents"

    files = {
      file_1_name => file_1_contents,
      file_2_name => file_2_contents,
      file_3_name => file_3_contents
    }.map { |k, v| { filename: k, content: v } }

    s3_client = mock
    s3_client.expects(:put_object).with(
      body: file_1_contents,
      bucket: Exercism.config.aws_iterations_bucket,
      key: "test/storage/#{iteration_uuid}/#{file_1_name}",
      acl: 'private'
    )

    s3_client.expects(:put_object).with(
      body: file_2_contents,
      bucket: Exercism.config.aws_iterations_bucket,
      key: "test/storage/#{iteration_uuid}/#{file_2_name}",
      acl: 'private'
    )

    s3_client.expects(:put_object).with(
      body: file_3_contents,
      bucket: Exercism.config.aws_iterations_bucket,
      key: "test/storage/#{iteration_uuid}/#{file_3_name}",
      acl: 'private'
    )

    Aws::S3::Client.expects(:new).times(3).with(Exercism.config.aws_auth).returns(s3_client)
    Iteration::UploadForStorage.(iteration_uuid, files)
  end
end
