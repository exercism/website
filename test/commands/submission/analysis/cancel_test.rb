require 'test_helper'

class Submission::Analysis::CancelTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    skip
    submission_uuid = SecureRandom.compact_uuid
    RestClient.expects(:post).with(
      'http://analyzer.example.com/submissions/cancel',
      submission_uuid:
    )
    Submission::Analysis::Cancel.(submission_uuid)
  end
end
