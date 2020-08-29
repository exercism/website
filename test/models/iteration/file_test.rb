require 'test_helper'

class IterationFileTest < ActiveSupport::TestCase
  test "record is created correctly" do
    filename = "some filename"
    digest = "some digest"
    content = "some content"
    iteration = create :iteration

    file = iteration.files.create!(
      filename: filename,
      digest: digest,
      content: content
    )

    assert_equal iteration, file.iteration
    assert_equal filename, file.filename
    assert_equal digest, file.digest

    # Note that this retreives from s3
    assert_equal content, file.content
  end
end
