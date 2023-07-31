require 'test_helper'

class Submission::Representation::CancelTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    skip
    submission_uuid = SecureRandom.compact_uuid
    RestClient.expects(:post).with('http://representer.example.com/submissions/cancel',
      submission_uuid:)
    Submission::Representation::Cancel.(submission_uuid)
  end
end
