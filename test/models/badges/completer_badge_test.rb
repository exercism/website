require "test_helper"

class Badge::CompleterBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :completer_badge
    assert_equal "Completer", badge.name
    assert_equal :ultimate, badge.rarity
    assert_equal :completer, badge.icon
    assert_equal 'Completed all exercises in a track', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    track = create :track
    create(:hello_world_exercise, track:)
    concept_exercise_1 = create :concept_exercise, track:, position: 1, slug: 'log-levels'
    concept_exercise_2 = create :concept_exercise, track:, position: 2, slug: 'magic-cards'
    practice_exercise_1 = create :practice_exercise, track:, position: 3, slug: 'leap'
    practice_exercise_2 = create :practice_exercise, track:, position: 4, slug: 'bob'
    create(:user_track, user:, track:)

    badge = create :completer_badge

    # Not completed any exercise
    refute badge.award_to?(user.reload)

    # Completing hello-world does not award the badge
    create(:hello_world_solution, :completed, user:, track:)
    refute badge.award_to?(user.reload)

    # Partially completing the concept exercises does not award the badge
    create :concept_solution, :completed, user:, track:, exercise: concept_exercise_1
    refute badge.award_to?(user.reload)

    # Fully completing the concept exercises does not award the badge
    create :concept_solution, :completed, user:, track:, exercise: concept_exercise_2
    refute badge.award_to?(user.reload)

    # Partially completing the practice exercises does not award the badge
    create :practice_solution, :completed, user:, track:, exercise: practice_exercise_1
    refute badge.award_to?(user.reload)

    # Fully completing the concept and practice exercises awards the badge
    create :practice_solution, :completed, user:, track:, exercise: practice_exercise_2
    assert badge.award_to?(user.reload)
  end

  test "don't award when completing inactive track" do
    user = create :user
    track = create :track, active: false
    create(:hello_world_exercise, track:)
    practice_exercise = create(:practice_exercise, track:)
    create(:user_track, user:, track:)

    badge = create :completer_badge

    # Fully completing the exercises does not award the badge
    create(:hello_world_solution, :completed, user:, track:)
    create :practice_solution, :completed, user:, track:, exercise: practice_exercise
    refute badge.award_to?(user.reload)
  end
end
