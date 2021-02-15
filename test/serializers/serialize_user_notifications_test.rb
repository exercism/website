require 'test_helper'

class SerializeUserNotificationsTest < ActiveSupport::TestCase
  test "basic request" do
    user = create :user
    mentor = create :user
    notification = create :mentor_started_discussion_notification,
      user: user,
      params: {
        discussion: create(:solution_mentor_discussion, mentor: mentor)
      }

    notifications = User::Notification::Retrieve.(user)

    expected = [
      {
        id: notification.uuid,
        url: notification.url,
        text: notification.text,
        is_read: false,
        created_at: notification.created_at.iso8601,
        image_type: :avatar,
        image_url: mentor.avatar_url
      }.with_indifferent_access
    ]

    assert_equal expected, SerializeUserNotifications.(notifications)
  end
end
