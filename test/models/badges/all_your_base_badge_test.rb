require "test_helper"

class Badge::AllYourBaseBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :all_your_base_badge
    assert_equal "All your base", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'all-your-base', badge.icon
    assert_equal 'Completed the "All Your Base" exercise', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    track = create :track
    badge = create :all_your_base_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # Completing hello-world does not award the badge
    create :hello_world_solution, :completed, user: user, track: track
    refute badge.award_to?(user.reload)

    # Completing different exercise does not award the badge
    leap_exercise = create :practice_exercise, slug: 'leap'
    create :practice_solution, :completed, user: user, track: track, exercise: leap_exercise
    refute badge.award_to?(user.reload)

    # Iterate the all-your-base exercise without completing does not award the badge
    all_your_base_exercise = create :practice_exercise, slug: 'all-your-base'
    solution = create :practice_solution, :iterated, user: user, track: track, exercise: all_your_base_exercise
    refute badge.award_to?(user.reload)

    # Complete the all-your-base exercise awards the badge
    solution.update(completed_at: Time.current)
    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    refute Badges::AllYourBaseBadge.worth_queuing?(exercise: nil)
    refute Badges::AllYourBaseBadge.worth_queuing?(exercise: 'hello-world')
    refute Badges::AllYourBaseBadge.worth_queuing?(exercise: 'bob')
    assert Badges::AllYourBaseBadge.worth_queuing?(exercise: 'all-your-base')
  end
end
