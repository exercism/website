require "test_helper"

class Badge::RookieBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :rookie_badge
    assert_equal "Rookie", badge.name
    assert_equal :common, badge.rarity
    assert_equal :editor, badge.icon
    assert_equal "Submitted an exercise", badge.description
  end

  test "award_to?" do
    user = create :user
    badge = create :rookie_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # Solution but no submissions
    solution = create :practice_solution, user: user
    refute badge.award_to?(user.reload)

    # Iteartions
    create :submission, solution: solution
    assert badge.award_to?(user.reload)
  end
end
