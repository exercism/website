require "test_helper"

class Badge::AnybodyThereBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :anybody_there_badge
    assert_equal "Anybody there?", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'hello-world', badge.icon
    assert_equal 'Completed "Hello, World!" in five languages', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :anybody_there_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # 4 hello worlds is not enough
    4.times do |idx|
      track = create :track, slug: "track_#{idx}"
      create :hello_world_solution, :completed, user:, track:
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th other exercise
    another_track = create :track, slug: "irrelevant"
    create :practice_solution, :completed, user:, track: another_track
    refute badge.award_to?(user.reload)

    # Add a 5th hello world, but not completed
    track = create :track, slug: "final_track"
    solution = create(:hello_world_solution, :iterated, user:, track:)
    refute badge.award_to?(user.reload)

    # Iterate it
    solution.update(completed_at: Time.current)
    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    refute Badges::AnybodyThereBadge.worth_queuing?(exercise: create(:practice_exercise, slug: 'leap'))
    refute Badges::AnybodyThereBadge.worth_queuing?(exercise: create(:practice_exercise, slug: 'bob'))
    assert Badges::AnybodyThereBadge.worth_queuing?(exercise: create(:practice_exercise, slug: 'hello-world'))
  end
end
