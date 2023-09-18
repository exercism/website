require "test_helper"

class Badge::WhateverBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :whatever_badge
    assert_equal "Whatever", badge.name
    assert_equal :common, badge.rarity
    assert_equal :whatever, badge.icon
    assert_equal 'Completed the "Bob" exercise', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    track = create :track
    badge = create :whatever_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # Completing hello-world does not award the badge
    create(:hello_world_solution, :completed, user:, track:)
    refute badge.award_to?(user.reload)

    # Completing different exercise does not award the badge
    leap_exercise = create :practice_exercise, slug: 'leap'
    create :practice_solution, :completed, user:, track:, exercise: leap_exercise
    refute badge.award_to?(user.reload)

    # Iterate the bob exercise without completing does not award the badge
    bob_exercise = create :practice_exercise, slug: 'bob'
    solution = create :practice_solution, :iterated, user:, track:, exercise: bob_exercise
    refute badge.award_to?(user.reload)

    # Complete the bob exercise awards the badge
    solution.update(completed_at: Time.current)
    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    refute Badges::WhateverBadge.worth_queuing?(exercise: create(:practice_exercise, slug: 'leap'))
    refute Badges::WhateverBadge.worth_queuing?(exercise: create(:practice_exercise, slug: 'hello-world'))
    assert Badges::WhateverBadge.worth_queuing?(exercise: create(:practice_exercise, slug: 'bob'))
  end
end
