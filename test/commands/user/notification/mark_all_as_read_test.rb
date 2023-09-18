require 'test_helper'

class User::Notifications::MarkAllAsReadTest < ActiveSupport::TestCase
  test "clears all notifications for user" do
    user = create :user
    notification = create(:notification, user:)
    other_notification = create :notification

    User::Notification::MarkAllAsRead.(user)

    assert notification.reload.read?
    refute other_notification.reload.read?
  end

  test "broadcasts message" do
    user = create :user
    create(:notification, user:)
    NotificationsChannel.expects(:broadcast_changed!).with(user)

    User::Notification::MarkAllAsRead.(user)
  end

  test "does not broadcast if none were changed" do
    user = create :user
    create :notification, user:, status: :read
    NotificationsChannel.expects(:broadcast_changed!).never

    User::Notification::MarkAllAsRead.(user)
  end
end
