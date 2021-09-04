require 'test_helper'

class User::AcquiredBadgeTest < ActiveSupport::TestCase
  test "only one badge can be created per user" do
    badge = create :rookie_badge
    user = create :user
    create :user_acquired_badge, user: user, badge: badge

    assert_raises do
      create :user_acquired_badge, user: user, badge: badge
    end
  end

  test "unrevealed scope" do
    user = create :user
    rookie_badge = create :rookie_badge
    member_badge = create :member_badge

    create :user_acquired_badge, revealed: true, badge: rookie_badge, user: user
    unrevealed = create :user_acquired_badge, revealed: false, badge: member_badge, user: user

    assert_equal [unrevealed], User::AcquiredBadge.unrevealed
  end
end
