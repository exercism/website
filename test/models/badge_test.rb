require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  test "percentage_awardees" do
    badge = create :rookie_badge, num_awardees: 4
    create_list(:user, 21, :not_mentor)

    assert_equal 9.76, badge.percentage_awardees
  end

  test "ordered_by_rarity" do
    rare = create :mentor_badge
    ultimate = create :completer_badge
    common = create :member_badge
    legendary = create :architect_badge
    assert_equal [legendary, ultimate, rare, common], Badge.ordered_by_rarity
  end
end
