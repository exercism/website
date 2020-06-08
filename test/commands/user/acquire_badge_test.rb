require "test_helper"

class User::AcquireBadgeTest < ActiveSupport::TestCase
  test "acquires badge for user" do
    user = create :user
    badge = create :badge

    user_badge = User::AcquireBadge.(user, badge)
    assert user_badge.persisted?
    assert_equal user, user_badge.user
    assert_equal badge, user_badge.badge
  end

  test "idempotent" do
    user = create :user
    badge = create :badge

    assert_idempotent_command { User::AcquireBadge.(user, badge) }
    assert_equal 1, user.notifications.count
  end

  test "creates notification" do
    user = create :user
    badge = create :badge

    user_badge = User::AcquireBadge.(user, badge)

    assert_equal 1, user.notifications.size
    notification = user.notifications.first
    assert_equal Notification::AcquiredBadgeNotification, notification.class
    assert_equal({user_badge: user_badge}, notification.send(:params))
  end
end
