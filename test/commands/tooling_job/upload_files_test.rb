require 'test_helper'

class ToolingJob::UploadFilesTest < ActiveSupport::TestCase
  test "uploads correct files" do
    exercise_files = {
      "bob.rb" => "stub content\n",
      "bob_test.rb" => "test content\n",
      "README.md" => "README content\n",
      "subdir/more_bob.rb" => "Original subdir solution file"
    }

    submission_files = {
      "subdir/more_bob.rb" => "Overriden subdir solution file", # Override old file
      "subdir/new_file.rb" => "New file contents", # Add new file
      "bob_test.rb" => "Overriden tests" # Don't override tests
      # ".meta/config.json" => "Overriden config" # Don't override tests
    }.map { |k, v| { filename: k, content: v } }

    job_id = "foobar"
    folder = "/tmp/exercism-tooling-jobs-efs/#{job_id}"

    {
      "bob.rb": "stub content\n",
      "bob_test.rb": "test content\n",
      "README.md": "README content\n",
      "subdir/more_bob.rb": "Overriden subdir solution file",
      "subdir/new_file.rb": "New file contents"
      # ".meta/config.json": "{\n  \"version\": \"15.8.12\"\n}\n"
    }.each do |filename, content|
      File.expects(:write).with("#{folder}/#{filename}", content)
    end

    ToolingJob::UploadFiles.(
      job_id, submission_files, exercise_files, /test/
    )
  end
end
