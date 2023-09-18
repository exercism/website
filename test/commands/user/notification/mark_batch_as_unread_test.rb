require 'test_helper'

class User::Notifications::MarkBatchAsUnreadTest < ActiveSupport::TestCase
  test "clears all notifications for user" do
    user = create :user
    notification = create :notification, user:, status: :read, read_at: Time.current
    other_notification = create :notification, user:, status: :read
    other_persons_notification = create :notification, status: :read

    User::Notification::MarkBatchAsUnread.(user, [notification.uuid, other_persons_notification.uuid])

    refute notification.reload.read?
    assert_nil notification.read_at

    assert other_notification.reload.read?
    assert other_persons_notification.reload.read?
  end

  test "broadcasts message" do
    user = create :user
    notification = create :notification, user:, status: :read
    NotificationsChannel.expects(:broadcast_changed!).with(user)

    User::Notification::MarkBatchAsUnread.(user, [notification.uuid])
  end

  test "does not broadcast if none were changed" do
    user = create :user
    notification = create :notification, user:, status: :unread
    NotificationsChannel.expects(:broadcast_changed!).never

    User::Notification::MarkBatchAsUnread.(user, [notification.uuid])
  end
end
