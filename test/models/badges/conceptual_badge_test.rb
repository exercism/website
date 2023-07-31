require "test_helper"

class Badge::ConceptualBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :conceptual_badge
    assert_equal "Conceptual", badge.name
    assert_equal :ultimate, badge.rarity
    assert_equal :conceptual, badge.icon
    assert_equal 'Completed all learning exercises in a track', badge.description
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

    badge = create :conceptual_badge

    # Not completed any exercise
    refute badge.award_to?(user.reload)

    # Completing hello-world does not award the badge
    create(:hello_world_solution, :completed, user:, track:)
    refute badge.award_to?(user.reload)

    # Partially completing the practice exercises does not award the badge
    create :practice_solution, :completed, user:, track:, exercise: practice_exercise_1
    refute badge.award_to?(user.reload)

    # Partially completing the concept exercises does not award the badge
    create :concept_solution, :completed, user:, track:, exercise: concept_exercise_1
    refute badge.award_to?(user.reload)

    # Fully completing the practice exercises does not awards the badge
    create :practice_solution, :completed, user:, track:, exercise: practice_exercise_2
    refute badge.award_to?(user.reload)

    # Fully completing the concept exercises awards the badge
    create :concept_solution, :completed, user:, track:, exercise: concept_exercise_2
    assert badge.award_to?(user.reload)
  end

  test "don't award when completing inactive track" do
    user = create :user
    track = create :track, active: false
    create(:hello_world_exercise, track:)
    concept_exercise = create(:concept_exercise, track:)
    create(:user_track, user:, track:)

    badge = create :conceptual_badge

    # Fully completing the concept exercises does not award the badge
    create(:hello_world_solution, :completed, user:, track:)
    create :concept_solution, :completed, user:, track:, exercise: concept_exercise
    refute badge.award_to?(user.reload)
  end

  test "don't award when completing track without learning mode" do
    user = create :user
    track = create :track, course: false
    create(:hello_world_exercise, track:)
    concept_exercise = create(:concept_exercise, track:)
    create(:user_track, user:, track:)

    badge = create :conceptual_badge

    # Fully completing the concept exercises does not award the badge
    create(:hello_world_solution, :completed, user:, track:)
    create :concept_solution, :completed, user:, track:, exercise: concept_exercise
    refute badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    refute Badges::ConceptualBadge.worth_queuing?(exercise: create(:practice_exercise))
    assert Badges::ConceptualBadge.worth_queuing?(exercise: create(:concept_exercise))
  end
end
