require "test_helper"

class Badge::AnybodyThereBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :anybody_there_badge
    assert_equal "Anybody there?", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'hello-world', badge.icon
    assert_equal 'Awarded for completing "Hello, World!" in five languages', badge.description
  end

  test "award_to?" do
    user = create :user
    badge = create :anybody_there_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # 4 hello worlds is not enough
    4.times do |idx|
      track = create :track, slug: "track_#{idx}"
      create :hello_world_solution, :iterated, user: user, track: track
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th other exercise
    another_track = create :track, slug: "irrelevant"
    create :practice_solution, :iterated, user: user, track: another_track
    refute badge.award_to?(user.reload)

    # Add a 5th hello world, but not iterated
    track = create :track, slug: "final_track"
    solution = create :hello_world_solution, user: user, track: track
    refute badge.award_to?(user.reload)

    # Iterate it
    solution.update_column(:status, :iterated)
    assert badge.award_to?(user.reload)
  end
end
