require "test_helper"

class Badge::CreateTest < ActiveSupport::TestCase
  test "acquires badge for user" do
    user = create :user

    user_badge = Badge::Create.(user, :first_submission)
    assert user_badge.persisted?
    assert_equal user, user_badge.user
    assert_equal Badges::FirstSubmissionBadge, user_badge.class
  end

  test "idempotent" do
    user = create :user

    assert_idempotent_command { Badge::Create.(user, :first_submission) }
    assert_equal 1, user.notifications.count
  end

  test "creates notification" do
    user = create :user

    badge = Badge::Create.(user, :first_submission)

    assert_equal 1, user.notifications.size
    notification = user.notifications.first
    assert_equal Notifications::AcquiredBadgeNotification, notification.class
    assert_equal({badge: badge}, notification.send(:params))
  end
end
