require 'test_helper'

class SerializeUserAcquiredBadgesTest < ActiveSupport::TestCase
  test "basic request" do
    user = create :user
    badge = create :rookie_badge
    acquired_badge = create :user_acquired_badge, revealed: false, badge: badge, user: user

    expected = {
      badges: [
        {
          id: acquired_badge.uuid,
          revealed: false,
          unlocked_at: acquired_badge.created_at.iso8601,
          name: "Rookie",
          description: "Submitted an exercise",
          rarity: :common,
          icon_name: :editor
        }
      ],
      links: {
        badges: Exercism::Routes.badges_journey_url
      }
    }

    assert_equal expected, SerializeUserAcquiredBadges.(user.acquired_badges)
  end
end
