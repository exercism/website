require "test_helper"

class Badge::SupporterBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :supporter_badge
    assert_equal "Supporter", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :supporter, badge.icon
    assert_equal "Donated to Exercism, helping fund free education for everyone", badge.description
  end

  test "award_to?" do
    user = create :user
    badge = create :supporter_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # Solution but no submissions
    user.update(total_donated_in_cents: 1)
    assert badge.award_to?(user)
  end
end
