require 'test_helper'

class SubmissionFileTest < ActiveSupport::TestCase
  test "record is created correctly" do
    filename = "some filename"
    digest = "some digest"
    content = "some content"
    submission = create :submission

    file = submission.files.create!(
      filename:,
      digest:,
      content:
    )

    assert_equal submission, file.submission
    assert_equal filename, file.filename
    assert_equal digest, file.digest

    # Get a new instance from the db so that we retrieve
    # from s3, not from the local cached version
    reloaded_file = Submission::File.find(file.id)
    assert_equal content, reloaded_file.content
    assert_equal content, File.read(reloaded_file.efs_path)
  end

  test "submit a file with weird encoding" do
    submission = create :submission
    file = submission.files.create!(
      filename: "some filename",
      digest: "some digest",
      content: "\xC2"
    )

    # Get a new instance from the db so that we retrieve
    # from s3, not from the local cached version
    reloaded_file = Submission::File.find(file.id)
    assert_equal "\xC2", File.read(reloaded_file.efs_path)

    # File should be turned into empty string
    # if it can't be turned into JSON.
    assert_equal "[Invalid Unicode]", reloaded_file.content
  end
end
