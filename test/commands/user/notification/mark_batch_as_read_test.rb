require 'test_helper'

class User::Notifications::MarkBatchAsReadTest < ActiveSupport::TestCase
  test "clears all notifications for user" do
    user = create :user
    notification = create(:notification, user:)
    other_notification = create(:notification, user:)
    other_persons_notification = create :notification

    User::Notification::MarkBatchAsRead.(user, [notification.uuid, other_persons_notification.uuid])

    assert notification.reload.read?
    refute other_notification.reload.read?
    refute other_persons_notification.reload.read?
  end

  test "broadcasts message" do
    user = create :user
    notification = create(:notification, user:)
    NotificationsChannel.expects(:broadcast_changed!).with(user)

    User::Notification::MarkBatchAsRead.(user, [notification.uuid])
  end

  test "does not broadcast if none were changed" do
    user = create :user
    notification = create :notification, user:, status: :read
    NotificationsChannel.expects(:broadcast_changed!).never

    User::Notification::MarkBatchAsRead.(user, [notification.uuid])
  end
end
