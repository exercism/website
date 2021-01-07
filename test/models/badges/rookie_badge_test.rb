require "test_helper"

class Badge::RookieBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :rookie_badge
    assert_equal "Rookie", badge.name
    assert_equal :common, badge.rarity
    assert_equal :editor, badge.icon
    assert_equal "Submitted an exercise", badge.description
  end

  test "should_award?" do
    user = create :user
    badge = -> { build(:rookie_badge, user: user.reload) }

    # No solutions
    refute badge.().should_award?

    # Solution but no submissions
    solution = create :practice_solution, user: user
    refute badge.().should_award?

    # Iteartions
    create :submission, solution: solution
    assert badge.().should_award?
  end
end
