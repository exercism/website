require 'test_helper'

class Iteration::UploadWithExerciseTest < ActiveSupport::TestCase
  test "uploads correct files" do
    solution = create :concept_solution
    iteration_uuid = SecureRandom.compact_uuid
    s3_client = mock

    iteration_files = {
      "subdir/more_bob.rb" => "Overriden subdir solution file", # Override old file
      "subdir/new_file.rb" => "New file contents", # Add new file
      "bob_test.rb" => "Overriden tests", # Don't override tests
      ".meta/config.json" => "Overriden config" # Don't override tests
    }.map { |k, v| { filename: k, content: v } }

    {
      "bob.rb": "stub content\n",
      "bob_test.rb": "test content\n",
      "README.md": "README content\n",
      "subdir/more_bob.rb": "Overriden subdir solution file",
      "subdir/new_file.rb": "New file contents",
      ".meta/config.json": "{\n  \"version\": \"15.8.12\"\n}\n"
    }.each do |filename, content|
      s3_client.expects(:put_object).with(
        bucket: Exercism.config.aws_iterations_bucket,
        key: "test/combined/#{iteration_uuid}/#{filename}",
        acl: 'private',
        body: content
      )
    end

    Aws::S3::Client.expects(:new).times(6).returns(s3_client)
    actual_s3_uri = Iteration::UploadWithExercise.(
      iteration_uuid, solution.git_slug, solution.git_sha, solution.track.repo, iteration_files
    )

    expected_s3_uri = "s3://#{Exercism.config.aws_iterations_bucket}/test/combined/#{iteration_uuid}"
    assert_equal expected_s3_uri, actual_s3_uri
  end
end
