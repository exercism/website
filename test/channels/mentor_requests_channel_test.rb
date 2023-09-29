require "test_helper"

class MentorRequestChannelTest < ActionCable::Channel::TestCase
  test ".broadcast_pending! broadcasts request" do
    request = create :mentor_request

    assert_broadcast_on(
      request,
      {
        mentor_request: {
          uuid: request.uuid,
          status: request.status
        }
      }
    ) do
      MentorRequestChannel.broadcast!(request)
    end
  end
end
