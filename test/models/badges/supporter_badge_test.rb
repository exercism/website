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
    user = create :user
    badge = create :supporter_badge

    # Not donated
    refute badge.award_to?(user.reload)

    # Donated! Yay!!
    user.update(first_donated_at: Time.current)
    assert badge.award_to?(user)
  end
end
