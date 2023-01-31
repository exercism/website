require "test_helper"

class Badge::ParticipantIn12In23BadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :participant_in_12_in_23_badge
    assert_equal "12 in 23", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'12-in-23', badge.icon # rubocop:disable Naming/VariableNumber
    assert_equal 'Participated in the #12in23 challenge and completed 5 exercises in a track', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    badge = create :participant_in_12_in_23_badge

    # No solutions
    refute badge.award_to?(user.reload)

    # Completed one exercise
    create :hello_world_solution, :completed, user: user, track: track
    refute badge.award_to?(user.reload)

    # Complete five exercises in track does not award badge as user hasn't yet participated
    4.times do
      exercise = create :practice_exercise, :random_slug, track: track
      create :practice_solution, :completed, user: user, track: track, exercise: exercise
      refute badge.award_to?(user.reload)
    end

    create :user_challenge, user: user, challenge_id: '12in23'

    # Complete four exercises after participating does not award the badge
    4.times do
      exercise = create :practice_exercise, :random_slug, track: track
      create :practice_solution, :completed, user: user, track: track, exercise: exercise
      refute badge.award_to?(user.reload)
    end

    # Completing exercise in different track does not award the badge
    exercise = create :practice_exercise, :random_slug, track: other_track
    create :practice_solution, :completed, user: user, track: other_track, exercise: exercise
    refute badge.award_to?(user.reload)

    # Iterate the fifth exercise without completing does not award the badge
    exercise = create :practice_exercise, slug: :random_slug, track: track
    solution = create :practice_solution, :iterated, user: user, track: track, exercise: exercise
    refute badge.award_to?(user.reload)

    # Complete the fifth exercise does not awards the badge
    solution.update(completed_at: Time.current)
    assert badge.award_to?(user.reload)
  end
end
