require "test_helper"

class Exercise::TaughtConceptTest < ActiveSupport::TestCase
  test "wired in correctly" do
    exercise = create :concept_exercise
    concept = create :concept
    taught_concept = create :exercise_taught_concept,
      exercise: exercise,
      concept: concept

    assert_equal exercise, taught_concept.exercise
    assert_equal concept, taught_concept.concept
  end

  test "num_concepts updated" do
    track = create :track
    c_1 = create :concept
    c_2 = create :concept
    c_3 = create :concept
    c_4 = create :concept

    # Sanity check
    assert_equal 0, track.num_concepts

    ce_1 = create :concept_exercise, track: track, status: :active
    create :exercise_taught_concept, exercise: ce_1, concept: c_1
    assert_equal 1, track.reload.num_concepts

    ce_2 = create :concept_exercise, track: track, status: :beta
    create :exercise_taught_concept, exercise: ce_2, concept: c_2
    assert_equal 2, track.reload.num_concepts

    # Sanity check: duplicate taught concept should not count
    ce_3 = create :concept_exercise, track: track, status: :active
    create :exercise_taught_concept, exercise: ce_3, concept: c_2
    assert_equal 2, track.reload.num_concepts

    # Sanity check: taught concepts in other track should not count
    ce_4 = create :concept_exercise, track: (create :track, :random_slug), status: :active
    create :exercise_taught_concept, exercise: ce_4, concept: c_3
    assert_equal 2, track.reload.num_concepts

    # Sanity check: taught concept of wip exercise should not count
    ce_5 = create :concept_exercise, track: track, status: :wip
    create :exercise_taught_concept, exercise: ce_5, concept: c_4
    assert_equal 2, track.reload.num_concepts

    # Sanity check: taught concept of deprecated exercise should not count
    ce_5 = create :concept_exercise, track: track, status: :deprecated
    create :exercise_taught_concept, exercise: ce_5, concept: c_4
    assert_equal 2, track.reload.num_concepts
  end
end
