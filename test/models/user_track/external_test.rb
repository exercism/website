require "test_helper"

class UserTrack::ExternalTest < ActiveSupport::TestCase
  test "hard-coded methods" do
    ut = UserTrack::External.new(mock)
    assert ut.external?
    assert_empty ut.learnt_concepts

    assert ut.exercise_unlocked?(nil)
    refute ut.exercise_completed?(nil)
    assert_equal :external, ut.exercise_status(nil)

    assert_equal 0, ut.num_completed_exercises
    assert_empty ut.unlocked_exercise_ids

    refute ut.concept_unlocked?(mock)
    refute ut.concept_learnt?(mock)
    refute ut.concept_mastered?(mock)
    assert_equal 0, ut.num_completed_exercises_for_concept(mock)

    assert_empty ut.unlocked_concept_ids
    assert_equal 0, ut.num_concepts_learnt
    assert_equal 0, ut.num_concepts_mastered
  end

  test "num_concepts" do
    track = create :track
    create :concept, track: track
    create :concept, track: track

    ut = UserTrack::External.new(track)
    assert_equal 2, ut.num_concepts
  end

  test "num_exercises_for_concept" do
    track = create :track
    concept_1 = create :concept, track: track
    concept_2 = create :concept, track: track

    ce_1 = create :concept_exercise, :random_slug, track: track
    ce_1.taught_concepts << concept_1

    ce_2 = create :concept_exercise, :random_slug, track: track
    ce_2.prerequisites << concept_1 # This should not be counted
    ce_1.taught_concepts << concept_2

    pe_1 = create :practice_exercise, :random_slug, track: track
    pe_1.prerequisites << concept_1
    pe_1.prerequisites << concept_2

    pe_2 = create :practice_exercise, :random_slug, track: track
    pe_2.prerequisites << concept_1

    ut = UserTrack::External.new(track)
    assert_equal 3, ut.num_exercises_for_concept(concept_1)
    assert_equal 2, ut.num_exercises_for_concept(concept_2)
  end

  test "exercises" do
    track = create :track
    user_track = UserTrack::External.new(track)

    create :concept_exercise, :random_slug, track: track, status: :wip
    beta_concept_exercise = create :concept_exercise, :random_slug, track: track, status: :beta
    active_concept_exercise = create :concept_exercise, :random_slug, track: track, status: :active
    create :concept_exercise, :random_slug, track: track, status: :deprecated

    create :practice_exercise, :random_slug, track: track, status: :wip
    beta_practice_exercise = create :practice_exercise, :random_slug, track: track, status: :beta
    active_practice_exercise = create :practice_exercise, :random_slug, track: track, status: :active
    create :practice_exercise, :random_slug, track: track, status: :deprecated

    # wip and deprecated exercises are not included
    assert_equal [
      beta_concept_exercise,
      active_concept_exercise,
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.exercises.map(&:slug).sort
  end

  test "concept_exercises" do
    track = create :track
    user_track = UserTrack::External.new(track)

    create :concept_exercise, :random_slug, track: track, status: :wip
    beta_concept_exercise = create :concept_exercise, :random_slug, track: track, status: :beta
    active_concept_exercise = create :concept_exercise, :random_slug, track: track, status: :active
    create :concept_exercise, :random_slug, track: track, status: :deprecated

    # Sanity check: practice exercise should not be included
    create :practice_exercise, :random_slug, track: track

    # wip and deprecated exercises are not included
    assert_equal [
      beta_concept_exercise,
      active_concept_exercise
    ].map(&:slug).sort, user_track.concept_exercises.map(&:slug).sort
  end

  test "practice_exercises" do
    track = create :track
    user_track = UserTrack::External.new(track)

    create :practice_exercise, :random_slug, track: track, status: :wip
    beta_practice_exercise = create :practice_exercise, :random_slug, track: track, status: :beta
    active_practice_exercise = create :practice_exercise, :random_slug, track: track, status: :active
    create :practice_exercise, :random_slug, track: track, status: :deprecated

    # Sanity check: concept exercise should not be included
    create :concept_exercise, :random_slug, track: track

    # wip and deprecated exercises are not included
    assert_equal [
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.practice_exercises.map(&:slug).sort
  end
end
