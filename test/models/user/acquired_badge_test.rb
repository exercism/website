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
end
