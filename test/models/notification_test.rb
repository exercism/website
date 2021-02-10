require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  test "read, unread, read? and read!" do
    freeze_time do
      user = create :user
      notification = create :notification, user: user
      refute notification.read?
      assert_equal [], user.notifications.read
      assert_equal [notification], user.notifications.unread

      notification.read!
      assert notification.read?
      assert_equal Time.current, notification.read_at
      assert_equal [notification], user.notifications.read
      assert_equal [], user.notifications.unread
    end
  end

  test "text is sanitized" do
    notification = Notification.new
    notification.define_singleton_method(:i18n_params) do
      { user: "<foo>d</foo>angerous" }
    end

    I18n.expects(:t).with(
      "notifications.notification.",
      { user: "dangerous" }
    ).returns("")

    notification.text
  end
end
