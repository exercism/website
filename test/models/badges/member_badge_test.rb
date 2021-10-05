require "test_helper"

class Badge::MemberBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :member_badge
    assert_equal "Member", badge.name
    assert_equal :common, badge.rarity
    assert_equal :logo, badge.icon
    assert_equal "Awarded for joining Exercism", badge.description
    refute badge.send_email_on_acquisition?
  end

  test "award_to?" do
    assert build(:member_badge).award_to?(nil)
  end
end
