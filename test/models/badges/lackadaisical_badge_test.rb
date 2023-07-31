require "test_helper"

class Badges::LackadaisicalBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :lackadaisical_badge
    assert_equal "Lackadaisical", badge.name
    assert_equal :ultimate, badge.rarity
    assert_equal :lackadaisical, badge.icon
    assert_equal 'Completed the "Bob" exercise in five languages', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :lackadaisical_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      other_track = create :track, slug: "track_#{idx}"
      exercise = create :practice_exercise, slug: 'bob', track: other_track
      create :practice_solution, :completed, user:, track: other_track, exercise:
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th other exercise
    another_track = create :track, slug: "irrelevant"
    another_exercise = create :practice_exercise, slug: 'leap', track: another_track
    create :practice_solution, :completed, user:, track: another_track, exercise: another_exercise
    refute badge.award_to?(user.reload)

    # Add a 5th bob, but not completed
    track = create :track, slug: "final"
    exercise = create(:practice_exercise, slug: 'bob', track:)
    solution = create(:practice_solution, :iterated, user:, track:, exercise:)
    refute badge.award_to?(user.reload)

    # Iterate it
    solution.update(completed_at: Time.current)
    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    refute Badges::LackadaisicalBadge.worth_queuing?(exercise: create(:practice_exercise, slug: 'leap'))
    refute Badges::LackadaisicalBadge.worth_queuing?(exercise: create(:practice_exercise, slug: 'hello-world'))
    assert Badges::LackadaisicalBadge.worth_queuing?(exercise: create(:practice_exercise, slug: 'bob'))
  end
end
