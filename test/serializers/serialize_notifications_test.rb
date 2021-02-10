require 'test_helper'

class SerializeNotificationsTest < ActiveSupport::TestCase
  test "basic request" do
    user = create :user
    mentor = create :user
    notification = create :mentor_started_discussion_notification,
      user: user,
      params: {
        discussion: create(:solution_mentor_discussion, mentor: mentor)
      }

    notifications = Notification::Retrieve.(user)

    expected = [
      {
        id: notification.id,
        url: notification.url,
        text: notification.text,
        read: false,
        created_at: notification.created_at,
        image_type: :avatar,
        image_url: mentor.avatar_url
      }
    ]

    assert_equal expected, SerializeNotifications.(notifications)
  end
end
