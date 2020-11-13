require "test_helper"

class UserTrack::ExternalTest < ActiveSupport::TestCase
  test "hard-coded methods" do
    ut = UserTrack::External.new(mock)
    assert ut.external?
    assert_equal [], ut.learnt_concepts

    refute ut.exercise_available?(mock)
    refute ut.exercise_completed?(mock)

    assert_equal 0, ut.num_completed_exercises
    assert_equal [], ut.available_exercise_ids

    refute ut.concept_available?(mock)
    refute ut.concept_learnt?(mock)
    refute ut.concept_mastered?(mock)
    assert_equal 0, ut.num_completed_exercises_for_concept(mock)

    assert_equal [], ut.available_concept_ids
    assert_equal 0, ut.num_concepts_mastered
  end

  test "num_concepts" do
    track = create :track
    create :track_concept, track: track
    create :track_concept, track: track

    ut = UserTrack::External.new(track)
    assert_equal 2, ut.num_concepts
  end

  test "num_exercises_for_concept" do
    track = create :track
    concept_1 = create :track_concept, track: track
    concept_2 = create :track_concept, track: track

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
end
