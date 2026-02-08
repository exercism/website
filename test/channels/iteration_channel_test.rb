require "test_helper"

class IterationChannelTest < ActionCable::Channel::TestCase
  test "rejects subscription for an unauthorized connection" do
    user = create :user
    iteration = create :iteration
    stub_connection(current_user: user)

    subscribe uuid: iteration.uuid

    assert subscription.rejected?
    assert_no_streams
  end
end
