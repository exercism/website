require "test_helper"

class Badge::CreateTest < ActiveSupport::TestCase
  class Badges::DummyGoodBadge < Badge
    def should_award?
      true
    end
  end 

  class Badges::DummyBadBadge < Badge
    def should_award?
      false
    end
  end

  test "acquires badge for user" do
    user = create :user

    badge = Badge::Create.(user, :dummy_good)
    assert badge.persisted?
    assert_equal user, badge.user
    assert_equal Badges::DummyGoodBadge, badge.class
  end

  test "idempotent" do
    user = create :user

    assert_idempotent_command { Badge::Create.(user, :dummy_good) }
    assert_equal 1, user.notifications.count
  end

  # We create the badge as normal
  # but the first find shouldn't return it, triggering
  # the creation to continue as normal
  test "race conditions" do
    user = create :user
    badge = Badges::DummyGoodBadge.create!(user: user)
    Badges::DummyGoodBadge.expects(:find_by).returns(nil)
    Badges::DummyGoodBadge.expects(:find_by!).returns(badge)

    new_badge = Badge::Create.(user, :dummy_good)
    assert_equal badge, new_badge
  end

  test "creates notification" do
    user = create :user

    badge = Badge::Create.(user, :dummy_good)

    assert_equal 1, user.notifications.size
    notification = user.notifications.first
    assert_equal Notifications::AcquiredBadgeNotification, notification.class
    assert_equal({ badge: badge }, notification.send(:params))
  end

  test "raises if the badge shouldn't be awarded" do
    user = create :user

    assert_raises BadgeCriteriaNotFulfilledError do
      Badge::Create.(user, :dummy_bad)
    end
  end
end
