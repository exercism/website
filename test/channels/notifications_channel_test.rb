require "test_helper"

class NotificationsChannelTest < ActionCable::Channel::TestCase
  test ".broadcast_changed broadcasts unread notification count by default" do
    user = create(:user)
    create(:notification, read_at: nil, user: user)
    assert_broadcast_on(
      NotificationsChannel.broadcasting_for(user),
      { type: "notifications.changed", payload: { count: 1 } }
    ) do
      NotificationsChannel.broadcast_changed(user)
    end
  end

  test ".broadcast_changed broadcasts notification count" do
    user = create(:user)
    assert_broadcast_on(
      NotificationsChannel.broadcasting_for(user),
      { type: "notifications.changed", payload: { count: 10 } }
    ) do
      NotificationsChannel.broadcast_changed(user, count: 10)
    end
  end
end
