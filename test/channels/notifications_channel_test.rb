require "test_helper"

class NotificationsChannelTest < ActionCable::Channel::TestCase
  test ".broadcast_pending! broadcasts path" do
    user = create :user
    notification = create(:notification, user:)

    assert_broadcast_on(
      user,
      type: "notifications.pending",
      notification_id: notification.uuid,
      notification_path: notification.path
    ) do
      NotificationsChannel.broadcast_pending!(user, notification)
    end
  end

  test ".broadcast_changed! broadcasts message" do
    user = create :user

    assert_broadcast_on(
      user,
      type: "notifications.changed"
    ) do
      NotificationsChannel.broadcast_changed!(user)
    end
  end
end
