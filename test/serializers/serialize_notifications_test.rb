require 'test_helper'

class SerializeNotificationsTest < ActiveSupport::TestCase
  test "basic request" do
    user = create :user
    notification = create :notification, user: user

    notifications = Notification::Retrieve.(user)

    expected = [
      {
        id: notification.id,
        text: notification.text,
        read: false,
        url: "/"
      }
    ]

    assert_equal expected, SerializeNotifications.(notifications)
  end
end
