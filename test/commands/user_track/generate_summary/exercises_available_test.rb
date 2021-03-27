require "test_helper"

class UserTrack::Summary::ExercisesunlockedTest < ActiveSupport::TestCase
  test "exercise_unlocked? with no prerequisites" do
    track = create :track
    exercise = create :concept_exercise, :random_slug, track: track
    user_track = create :user_track, track: track
    assert summary_for(user_track).exercise_unlocked?(exercise)
  end

  test "exercise_unlocked? with prerequisites" do
    track = create :track
    user_track = create :user_track, track: track
    exercise = create :concept_exercise, :random_slug, track: track

    prereq_1 = create :track_concept, track: track
    create(:exercise_prerequisite, exercise: exercise, concept: prereq_1)

    prereq_2 = create :track_concept, track: track
    create(:exercise_prerequisite, exercise: exercise, concept: prereq_2)

    refute summary_for(user_track).exercise_unlocked?(exercise)

    create :user_track_learnt_concept, concept: prereq_1, user_track: user_track
    refute summary_for(user_track).exercise_unlocked?(exercise)

    create :user_track_learnt_concept, concept: prereq_2, user_track: user_track
    assert summary_for(user_track).exercise_unlocked?(exercise)
  end

  test "unlocked concepts" do
    track = create :track
    basics = create :track_concept, track: track, slug: "co_basics"
    enums = create :track_concept, track: track, slug: "co_enums"
    strings = create :track_concept, track: track, slug: "co_strings"

    # Nothing teaches recursion
    recursion = create :track_concept, track: track, slug: "co_recursion"

    basics_exercise = create :concept_exercise, slug: "ex_basics", track: track
    basics_exercise.taught_concepts << basics

    enums_exercise = create :concept_exercise, slug: "ex_enums", track: track
    enums_exercise.prerequisites << basics
    enums_exercise.taught_concepts << enums

    strings_exercise = create :concept_exercise, slug: "ex_strings", track: track
    strings_exercise.prerequisites << enums
    strings_exercise.prerequisites << basics
    strings_exercise.taught_concepts << strings

    user = create :user
    user_track = create :user_track, track: track, user: user

    summary = summary_for(user_track)
    assert_equal [basics, recursion].map(&:id), summary.unlocked_concept_ids
    assert summary.concept_unlocked?(recursion)
    assert summary.concept_unlocked?(basics)
    refute summary.concept_unlocked?(enums)
    refute summary.concept_unlocked?(strings)

    create :user_track_learnt_concept, user_track: user_track, concept: basics

    summary = summary_for(user_track)
    assert_equal [basics, enums, recursion].map(&:id), summary.unlocked_concept_ids
    assert summary.concept_unlocked?(recursion)
    assert summary.concept_unlocked?(basics)
    assert summary.concept_unlocked?(enums)
    refute summary.concept_unlocked?(strings)

    create :user_track_learnt_concept, user_track: user_track, concept: enums

    summary = summary_for(user_track)
    assert_equal [basics, enums, strings, recursion].map(&:id), summary.unlocked_concept_ids
    assert summary.concept_unlocked?(recursion)
    assert summary.concept_unlocked?(basics)
    assert summary.concept_unlocked?(enums)
    assert summary.concept_unlocked?(strings)
  end

  test "unlocked exercises" do
    track = create :track
    concept_exercise_1 = create :concept_exercise, :random_slug, track: track
    concept_exercise_2 = create :concept_exercise, :random_slug, track: track
    concept_exercise_3 = create :concept_exercise, :random_slug, track: track
    concept_exercise_4 = create :concept_exercise, :random_slug, track: track

    practice_exercise_1 = create :practice_exercise, :random_slug, track: track
    practice_exercise_2 = create :practice_exercise, :random_slug, track: track
    practice_exercise_3 = create :practice_exercise, :random_slug, track: track
    practice_exercise_4 = create :practice_exercise, :random_slug, track: track

    prereq_1 = create :track_concept, track: track
    prereq_2 = create :track_concept, track: track

    create(:exercise_prerequisite, exercise: concept_exercise_2, concept: prereq_1)
    create(:exercise_prerequisite, exercise: practice_exercise_2, concept: prereq_1)
    create(:exercise_prerequisite, exercise: concept_exercise_3, concept: prereq_1)
    create(:exercise_prerequisite, exercise: practice_exercise_3, concept: prereq_1)
    create(:exercise_prerequisite, exercise: concept_exercise_3, concept: prereq_2)
    create(:exercise_prerequisite, exercise: practice_exercise_3, concept: prereq_2)
    create(:exercise_prerequisite, exercise: concept_exercise_4, concept: prereq_2)
    create(:exercise_prerequisite, exercise: practice_exercise_4, concept: prereq_2)
    user_track = create :user_track, track: track

    summary = summary_for(user_track)
    assert_equal [
      concept_exercise_1, practice_exercise_1
    ].map(&:id).sort, summary.unlocked_exercise_ids.sort

    create :user_track_learnt_concept, concept: prereq_1, user_track: user_track
    summary = summary_for(user_track)
    assert_equal [
      concept_exercise_1,
      practice_exercise_1,
      concept_exercise_2,
      practice_exercise_2
    ].map(&:id).sort, summary.unlocked_exercise_ids.sort

    create :user_track_learnt_concept, concept: prereq_2, user_track: user_track
    summary = summary_for(user_track)
    assert_equal [
      concept_exercise_1, practice_exercise_1,
      concept_exercise_2, concept_exercise_3, concept_exercise_4,
      practice_exercise_2, practice_exercise_3, practice_exercise_4
    ].map(&:id).sort, summary.unlocked_exercise_ids.sort
  end

  private
  def summary_for(user_track)
    user_track = UserTrack.find(user_track.id)
    UserTrack::GenerateSummary.(user_track.track, user_track)
  end
end
