require "test_helper"

class Badge::DieUnendlicheGeschichteBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :die_unendliche_geschichte_badge
    assert_equal "Die Unendliche Geschichte", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'die-unendliche-geschichte', badge.icon
    assert_equal 'Submitted 10 iterations to the same exercise', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    track = create :track
    badge = create :die_unendliche_geschichte_badge
    exercise = create :practice_exercise, track: track
    solution = create :practice_solution, user: user, exercise: exercise

    # No solutions
    refute badge.award_to?(user.reload)

    # Solution with 9 iterations is not enough
    9.times do |_idx|
      create :iteration, solution: solution
    end
    refute badge.award_to?(user.reload)

    # Ignore iteration on same exercise in different track
    other_track = create :track, slug: 'other_track'
    other_track_exercise = create :practice_exercise, slug: exercise.slug, track: other_track
    other_solution = create :practice_solution, user: user, exercise: other_track_exercise
    create :iteration, solution: other_solution
    refute badge.award_to?(user.reload)

    # Ignore iteration on different solution in same track
    other_exercise = create :practice_exercise, slug: 'other_exercise', track: track
    other_solution = create :practice_solution, user: user, exercise: other_exercise
    create :iteration, solution: other_solution
    refute badge.award_to?(user.reload)

    # Add a 10th iteration
    create :iteration, solution: solution
    assert badge.award_to?(user.reload)
  end
end
