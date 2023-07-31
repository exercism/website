require "test_helper"

class Badge::GrowthMindsetBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :growth_mindset_badge
    assert_equal "Growth mindset", badge.name
    assert_equal :common, badge.rarity
    assert_equal :mentoring, badge.icon
    assert_equal "Iterated a solution while working with a mentor", badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :growth_mindset_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # Iterated solution
    solution = create(:practice_solution, user:)
    solution.update_column(:last_iterated_at, Time.current - 1.week)
    refute badge.award_to?(user.reload)

    # Discusssion without new iteartion
    create :mentor_discussion, solution:, created_at: Time.current - 1.day
    refute badge.award_to?(user.reload)

    # Extra iteration
    solution.update_column(:last_iterated_at, Time.current)
    assert badge.award_to?(user.reload)
  end
end
