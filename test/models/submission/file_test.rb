require 'test_helper'

class SubmissionFileTest < ActiveSupport::TestCase
  test "record is created correctly" do
    filename = "some filename"
    digest = "some digest"
    content = "some content"
    submission = create :submission

    file = submission.files.create!(
      filename: filename,
      digest: digest,
      content: content
    )

    assert_equal submission, file.submission
    assert_equal filename, file.filename
    assert_equal digest, file.digest

    # Note that this retreives from s3
    assert_equal content, file.content
  end
end
