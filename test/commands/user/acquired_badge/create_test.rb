require "test_helper"

class User::AcquiredBadge::CreateTest < ActiveSupport::TestCase
  test "acquires badge for user" do
    user = create :user

    acquired_badge = User::AcquiredBadge::Create.(user, :member)
    assert acquired_badge.persisted?
    assert_equal user, acquired_badge.user
    assert_equal Badges::MemberBadge, acquired_badge.badge.class
  end

  test "idempotent" do
    user = create :user

    assert_idempotent_command { User::AcquiredBadge::Create.(user, :member) }
    assert_equal 1, user.notifications.count
  end

  # We create the badge as normal
  # but the first find shouldn't return it, triggering
  # the creation to continue as normal
  test "race conditions" do
    badge = create :member_badge

    user = create :user
    acquired_badge = User::AcquiredBadge.create!(user: user, badge: badge)
    User::AcquiredBadge.expects(:find_by).returns(nil)
    User::AcquiredBadge.expects(:find_by!).returns(acquired_badge)

    new_badge = User::AcquiredBadge::Create.(user, :member)
    assert_equal acquired_badge, new_badge
  end

  test "creates notification" do
    user = create :user

    badge = User::AcquiredBadge::Create.(user, :member)

    assert_equal 1, user.notifications.size
    notification = User::Notification.where(user: user).first
    assert_equal User::Notifications::AcquiredBadgeNotification, notification.class
    assert_equal(
      { badge: badge.to_global_id.to_s }.with_indifferent_access,
      notification.send(:params)
    )
  end

  test "raises if the badge shouldn't be awarded" do
    user = create :user

    assert_raises BadgeCriteriaNotFulfilledError do
      User::AcquiredBadge::Create.(user, :rookie)
    end
  end
end
