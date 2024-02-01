require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  test "percentage_awardees" do
    badge = create :rookie_badge
    badge.update!(num_awardees: 4)
    # Ideally we'd run Infrastructure::AnalyzeTable.(User.table_name) here
    # but that breaks the transaction and totally screws up the tests :)
    # So we do this instead
    badge.stubs(num_users: 21)

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
