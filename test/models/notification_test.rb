require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  test "read, unread, read? and read!" do
    Timecop.freeze do
      notification = create :notification
      refute notification.read?
      assert_equal [], Notification.read
      assert_equal [notification], Notification.unread

      notification.read!
      assert notification.read?
      assert_equal Time.current, notification.read_at
      assert_equal [notification], Notification.read
      assert_equal [], Notification.unread
    end
  end
end
