require "test_helper"

class Badge::SupporterBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :supporter_badge
    assert_equal "Supporter", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :supporter, badge.icon
    assert_equal "Donated to Exercism, helping fund free education", badge.description
    refute badge.send_email_on_acquisition?
  end

  test "award_to?" do
    user = create :user, donated: false
    badge = create :supporter_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # Solution but no submissions
    user.update(donated: true)
    assert badge.award_to?(user)
  end
end
