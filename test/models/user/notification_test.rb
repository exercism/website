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
    notification = User::Notification.new
    notification.define_singleton_method(:i18n_params) do
      { user: "<foo>d</foo>angerous" }
    end

    I18n.expects(:t).with(
      "notifications.notification.",
      { user: "dangerous" }
    ).returns("")

    notification.text
  end

  test "rendering_data" do
    mentor = create :user
    notification = create :mentor_started_discussion_notification,
      params: {
        discussion: create(:solution_mentor_discussion, mentor: mentor)
      }

    expected = {
      id: notification.uuid,
      url: notification.url,
      text: notification.text,
      is_read: false,
      created_at: notification.created_at.iso8601,
      image_type: 'avatar',
      image_url: mentor.avatar_url
    }.with_indifferent_access

    assert_equal expected, notification.rendering_data
  end
end
