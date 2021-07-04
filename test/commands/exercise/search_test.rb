require "test_helper"

class Exercise::SearchTest < ActiveSupport::TestCase
  test "filters by track" do
    track = create :track, slug: "js"
    concept_exercise = create :concept_exercise, track: track
    practice_exercise = create :practice_exercise, track: track

    # Create on a different rack
    create :concept_exercise

    assert_equal [concept_exercise, practice_exercise], Exercise::Search.(track)
  end

  test "criteria" do
    track = create :track
    food = create :concept_exercise, title: "Food Chain", track: track
    bob = create :concept_exercise, title: "Bob", track: track

    assert_equal [food, bob], Exercise::Search.(track)
    assert_equal [food, bob], Exercise::Search.(track, criteria: " ")
    assert_equal [food], Exercise::Search.(track, criteria: "fo")
    assert_equal [bob], Exercise::Search.(track, criteria: "bo")
  end

  test "sorts correctly" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track
    concept = create :concept, track: track
    ce_locked_1 = create :concept_exercise, slug: "ce_locked_1", track: track, position: 7
    ce_locked_2 = create :concept_exercise, slug: "ce_locked_2", track: track, position: 12
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
    pe_locked.prerequisites << concept

    assert_equal [
      pe_iterated,
      ce_started,
      pe_started,
      pe_available,
      pe_completed,
      pe_published,
      ce_locked_1,
      ce_locked_2,
      pe_locked
    ].map(&:slug), Exercise::Search.(track, user_track: user_track).map(&:slug)
  end
end
