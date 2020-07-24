require 'test_helper'

class Iteration::Representation::CancelTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    skip
    iteration_uuid = SecureRandom.compact_uuid
    RestClient.expects(:post).with('http://representer.example.com/iterations/cancel',
                                   iteration_uuid: iteration_uuid)
    Iteration::Representation::Cancel.(iteration_uuid)
  end
end
