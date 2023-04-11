require "test_helper"

class Badge::RookieBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :rookie_badge
    assert_equal "Rookie", badge.name
    assert_equal :common, badge.rarity
    assert_equal :editor, badge.icon
    assert_equal "Submitted an exercise", badge.description
    refute badge.send_email_on_acquisition?
  end

  test "award_to?" do
    user = create :user
    badge = create :rookie_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # Solution but no submissions
    solution = create(:practice_solution, user:)
    refute badge.award_to?(user.reload)

    # Iterations
    create(:submission, solution:)
    refute badge.award_to?(user.reload)

    # Iterations
    create(:iteration, solution:)
    assert badge.award_to?(user.reload)
  end
end
