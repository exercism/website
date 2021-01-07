require "test_helper"

class Badge::MemberBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :member_badge
    assert_equal "Member", badge.name
    assert_equal :common, badge.rarity
    assert_equal :logo, badge.icon
    assert_equal "Joined Exercism", badge.description
  end

  test "should_award?" do
    assert build(:member_badge).should_award?
  end
end
