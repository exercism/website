require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  test "percentage_awardees" do
    badge = Badge.find_by_slug!(:rookie) # rubocop:disable Rails/DynamicFindBy
    badge.stubs(num_users: 21)
    badge.update!(num_awardees: 4)

    assert_equal 19.05, badge.percentage_awardees
  end

  test "ordered_by_rarity" do
    rare = create :mentor_badge
    ultimate = create :completer_badge
    common = create :member_badge
    legendary = create :architect_badge
    assert_equal [legendary, ultimate, rare, common], Badge.ordered_by_rarity
  end
end
