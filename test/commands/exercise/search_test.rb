require "test_helper"

class Exercise::SearchTest < ActiveSupport::TestCase
  test "filters by track" do
    track = create :track, slug: "js"
    user_track = UserTrack::External.new(track)

    concept_exercise = create :concept_exercise, track: track, position: 1
    practice_exercise = create :practice_exercise, track: track, position: 2

    # Create on a different rack
    create :concept_exercise

    assert_equal [concept_exercise, practice_exercise], Exercise::Search.(user_track)
  end

  test "criteria" do
    track = create :track
    user_track = UserTrack::External.new(track)

    food = create :concept_exercise, title: "Food Chain", track: track, position: 1
    bob = create :concept_exercise, title: "Bob", track: track, position: 2

    assert_equal [food, bob], Exercise::Search.(user_track)
    assert_equal [food, bob], Exercise::Search.(user_track, criteria: " ")
    assert_equal [food], Exercise::Search.(user_track, criteria: "fo")
    assert_equal [bob], Exercise::Search.(user_track, criteria: "bo")
    assert_equal [food], Exercise::Search.(user_track, criteria: "chain")
    assert_equal [bob], Exercise::Search.(user_track, criteria: "bob")
  end

  test "beta and active exercises are always shown" do
    track = create :track
    user_track = UserTrack::External.new(track)

    ce_active = create :concept_exercise, track: track, position: 1, status: :active
    ce_beta = create :concept_exercise, track: track, position: 2, status: :beta

    pe_active = create :practice_exercise, track: track, position: 5, status: :active
    pe_beta = create :practice_exercise, track: track, position: 6, status: :beta

    assert_equal [ce_active, ce_beta, pe_active, pe_beta], Exercise::Search.(user_track)
  end

  test "wip exercises are not shown" do
    # TODO: (Optional): show wip exercises for maintainers
    track = create :track
    user_track = UserTrack::External.new(track)

    concept_exercise = create :concept_exercise, track: track, position: 1, status: :active
    create :concept_exercise, track: track, position: 3, status: :wip

    practice_exercise = create :practice_exercise, track: track, position: 5, status: :active
    create :practice_exercise, track: track, position: 6, status: :wip

    assert_equal [concept_exercise, practice_exercise], Exercise::Search.(user_track)
  end

  test "does not show deprecated exercises when user has not started track" do
    track = create :track
    user_track = UserTrack::External.new(track)

    concept_exercise = create :concept_exercise, track: track, position: 1, status: :active
    create :concept_exercise, track: track, status: :deprecated

    practice_exercise = create :practice_exercise, track: track, position: 5, status: :active
    create :practice_exercise, track: track, status: :deprecated

    assert_equal [concept_exercise, practice_exercise], Exercise::Search.(user_track)
  end

  test "does not show deprecated exercises when user has started track but not started exercise" do
    user = create :user
    track = create :track, slug: "js"

    concept_exercise = create :concept_exercise, track: track, position: 1, status: :active
    create :concept_exercise, track: track, status: :deprecated

    practice_exercise = create :practice_exercise, track: track, position: 5, status: :active
    create :practice_exercise, track: track, status: :deprecated

    user_track = create :user_track, user: user, track: track

    assert_equal [concept_exercise, practice_exercise], Exercise::Search.(user_track)
  end

  test "shows deprecated exercises when user has started track and started exercise" do
    user = create :user
    track = create :track

    user_track = create :user_track, user: user, track: track

    ce_active = create :concept_exercise, track: track, slug: 'ce_active', position: 1, status: :active
    ce_deprecated_started = create :concept_exercise, slug: 'ce_deprecated_started', track: track, position: 2, status: :deprecated
    create :concept_solution, :started, exercise: ce_deprecated_started, user: user

    pe_active = create :practice_exercise, track: track, slug: 'pe_active', position: 5, status: :active
    pe_deprecated_started = create :practice_exercise, slug: 'pe_deprecated_started', track: track, position: 6, status: :deprecated
    create :practice_solution, :iterated, exercise: pe_deprecated_started, user: user

    # Create deprecated exercises that the user has not started
    create :concept_exercise, track: track, slug: 'ce_deprecated_not_started', position: 3, status: :deprecated
    create :practice_exercise, track: track, slug: 'pe_deprecated_not_started', position: 7, status: :deprecated

    assert_equal [pe_deprecated_started, ce_deprecated_started, ce_active, pe_active], Exercise::Search.(user_track)
  end

  test "sorts correctly" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track
    concept = create :concept, track: track
    ce_locked_1 = create :concept_exercise, slug: "ce_locked_1", track: track, position: 7
    ce_locked_2 = create :concept_exercise, slug: "ce_locked_2", track: track, position: 12
    ce_locked_3 = create :concept_exercise, slug: "ce_locked_3", track: track, position: 8
    ce_started = create :concept_exercise, slug: "ce_started", track: track, position: 18

    pe_iterated = create :practice_exercise, slug: "pe_iterated", track: track, position: 5
    pe_started = create :practice_exercise, slug: "pe_started", track: track, position: 5
    pe_available = create :practice_exercise, slug: "pe_available", track: track, position: 5
    pe_locked = create :practice_exercise, slug: "pe_locked", track: track, position: 5
    pe_published = create :practice_exercise, slug: "pe_published", track: track, position: 5
    pe_completed = create :practice_exercise, slug: "pe_completed", track: track, position: 5

    create :concept_solution, :started, exercise: ce_started, user: user

    create :practice_solution, :iterated, exercise: pe_iterated, user: user
    create :practice_solution, :started, exercise: pe_started, user: user
    create :practice_solution, :published, exercise: pe_published, user: user
    create :practice_solution, :completed, exercise: pe_completed, user: user

    ce_locked_1.prerequisites << concept
    ce_locked_2.prerequisites << concept
    ce_locked_3.prerequisites << concept
    pe_locked.prerequisites << concept

    assert_equal [
      pe_iterated,
      ce_started,
      pe_started,
      pe_available,
      pe_completed,
      pe_published,
      ce_locked_1,
      ce_locked_3,
      ce_locked_2,
      pe_locked
    ].map(&:slug), Exercise::Search.(user_track).map(&:slug)
  end
end
