require "test_helper"

class IterationChannelTest < ActionCable::Channel::TestCase
  test "raises error for an unauthorized connection" do
    user = create :user
    iteration = create :iteration
    stub_connection(current_user: user)

    assert_raises IterationChannel::UnauthorizedConnectionError do
      subscribe uuid: iteration.uuid
    end

    assert_no_streams
  end
end
