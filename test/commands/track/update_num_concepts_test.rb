require "test_helper"

class Track::UpdateNumConceptsTest < ActiveSupport::TestCase
  test "num_concepts updated" do
    track = create :track
    c_1 = create :concept
    c_2 = create :concept
    c_3 = create :concept
    c_4 = create :concept

    # Sanity check
    Track::UpdateNumConcepts.(track)
    assert_equal 0, track.reload.num_concepts

    ce_1 = create :concept_exercise, track:, status: :active
    create :exercise_taught_concept, exercise: ce_1, concept: c_1
    Track::UpdateNumConcepts.(track)
    assert_equal 1, track.reload.num_concepts

    ce_2 = create :concept_exercise, track:, status: :beta
    create :exercise_taught_concept, exercise: ce_2, concept: c_2
    Track::UpdateNumConcepts.(track)
    assert_equal 2, track.reload.num_concepts

    # Sanity check: duplicate taught concept should not count
    ce_3 = create :concept_exercise, track:, status: :active
    create :exercise_taught_concept, exercise: ce_3, concept: c_2
    Track::UpdateNumConcepts.(track)
    assert_equal 2, track.reload.num_concepts

    # Sanity check: taught concepts in other track should not count
    ce_4 = create :concept_exercise, track: (create :track, :random_slug), status: :active
    create :exercise_taught_concept, exercise: ce_4, concept: c_3
    Track::UpdateNumConcepts.(track)
    assert_equal 2, track.reload.num_concepts

    # Sanity check: taught concept of wip exercise should not count
    ce_5 = create :concept_exercise, track:, status: :wip
    create :exercise_taught_concept, exercise: ce_5, concept: c_4
    Track::UpdateNumConcepts.(track)
    assert_equal 2, track.reload.num_concepts

    # Sanity check: taught concept of deprecated exercise should not count
    ce_5 = create :concept_exercise, track:, status: :deprecated
    create :exercise_taught_concept, exercise: ce_5, concept: c_4
    Track::UpdateNumConcepts.(track)
    assert_equal 2, track.reload.num_concepts
  end
end
