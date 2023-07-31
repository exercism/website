require 'test_helper'

class User::Notifications::ActivateTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "updates status" do
    notification = create :notification

    User::Notification::Activate.(notification)

    assert_equal :unread, notification.status
  end

  test "broadcasts message" do
    user = create :user
    notification = create(:notification, user:)
    NotificationsChannel.expects(:broadcast_changed!).with(user)

    User::Notification::Activate.(notification)
  end

  test "sends email" do
    user = create :user
    notification = create(:notification, user:)
    User::Notification::SendEmail.expects(:call).with(notification)

    User::Notification::Activate.(notification)
  end

  test "does not update or publish if already unread" do
    notification = create :notification, status: :unread

    NotificationsChannel.expects(:broadcast_changed!).never
    User::Notification::Activate.(notification)
    assert_equal :unread, notification.status
  end

  test "does not update or publish if read" do
    notification = create :notification, status: :read

    NotificationsChannel.expects(:broadcast_changed!).never
    User::Notification::Activate.(notification)
    assert_equal :read, notification.status
  end
end
