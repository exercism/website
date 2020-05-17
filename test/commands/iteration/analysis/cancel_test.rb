require 'test_helper'

class Iteration::Analysis::CancelTest < ActiveSupport::TestCase

  test "calls to publish_message" do
    iteration_uuid = SecureRandom.compact_uuid
    RestClient.expects(:post).with('http://analyzer.example.com/iterations/cancel',
      iteration_uuid: iteration_uuid,
    )
    Iteration::Analysis::Cancel.(iteration_uuid)
  end
end




