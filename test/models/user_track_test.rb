require "test_helper"

class UserTrackTest < ActiveSupport::TestCase
  test ".for! with models" do
    ut = random_of_many(:user_track)
    assert_equal ut, UserTrack.for!(ut.user, ut.track)
  end

  test ".for! with id and slug" do
    ut = random_of_many(:user_track)
    assert_equal ut, UserTrack.for!(ut.user.id, ut.track.slug)
  end

  test ".for! with handle and slug" do
    ut = random_of_many(:user_track)
    assert_equal ut, UserTrack.for!(ut.user.handle, ut.track.slug)
  end

  test ".for proxies to for!" do
    user = mock
    track = mock
    UserTrack.expects(:for!).with(user, track)
    UserTrack.for(user, track)
  end

  test ".for works" do
    ut = create :user_track
    assert_equal ut, UserTrack.for(ut.user, ut.track)
  end

  test ".for returns nil with invalid data" do
    ut = create :user_track
    assert_nil UserTrack.for(create(:user), ut.track)
    assert_nil UserTrack.for(ut.user, create(:track))
    assert_nil UserTrack.for(ut.user, nil)
    assert_nil UserTrack.for(nil, ut.track)
    assert_nil UserTrack.for(nil, nil)
  end

  test "exercise_available? with no prerequisites" do
    exercise = create :concept_exercise
    user_track = create :user_track, track: exercise.track
    assert user_track.exercise_available?(exercise)
  end

  test "exercise_available? with prerequisites" do
    track = create :track
    exercise = create :concept_exercise, :random_slug, track: track

    prereq_1 = create :track_concept, track: track
    create(:exercise_prerequisite, exercise: exercise, concept: prereq_1)

    prereq_2 = create :track_concept, track: track
    create(:exercise_prerequisite, exercise: exercise, concept: prereq_2)

    user_track = create :user_track, track: track
    refute user_track.exercise_available?(exercise)

    create :user_track_learnt_concept, concept: prereq_1, user_track: user_track
    refute UserTrack.find(user_track.id).exercise_available?(exercise)

    create :user_track_learnt_concept, concept: prereq_2, user_track: user_track
    assert UserTrack.find(user_track.id).exercise_available?(exercise)
  end

  test "available concepts" do
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

    assert_equal [basics, recursion], user_track.available_concepts
    assert user_track.concept_available?(recursion)
    assert user_track.concept_available?(basics)
    refute user_track.concept_available?(enums)
    refute user_track.concept_available?(strings)

    # Reload the user track to override memoizing
    user_track = UserTrack.find(user_track.id)

    create :user_track_learnt_concept, user_track: user_track, concept: basics

    assert_equal [basics, enums, recursion], user_track.available_concepts
    assert user_track.concept_available?(recursion)
    assert user_track.concept_available?(basics)
    assert user_track.concept_available?(enums)
    refute user_track.concept_available?(strings)

    # Reload the user track to override memoizing
    user_track = UserTrack.find(user_track.id)

    create :user_track_learnt_concept, user_track: user_track, concept: enums

    assert_equal [basics, enums, strings, recursion], user_track.available_concepts
    assert user_track.concept_available?(recursion)
    assert user_track.concept_available?(basics)
    assert user_track.concept_available?(enums)
    assert user_track.concept_available?(strings)
  end

  test "available exercises" do
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

    assert_equal [concept_exercise_1, practice_exercise_1], user_track.available_exercises
    assert_equal [concept_exercise_1], user_track.available_concept_exercises
    assert_equal [practice_exercise_1], user_track.available_practice_exercises

    # Reload the user track to override memoizing
    user_track = UserTrack.find(user_track.id)

    create :user_track_learnt_concept, concept: prereq_1, user_track: user_track
    assert_equal [
      concept_exercise_1,
      concept_exercise_2,
      practice_exercise_1,
      practice_exercise_2
    ], user_track.available_exercises

    assert_equal [concept_exercise_1, concept_exercise_2], user_track.available_concept_exercises
    assert_equal [practice_exercise_1, practice_exercise_2], user_track.available_practice_exercises

    # Reload the user track to override memoizing
    user_track = UserTrack.find(user_track.id)

    create :user_track_learnt_concept, concept: prereq_2, user_track: user_track
    assert_equal [
      concept_exercise_1, concept_exercise_2, concept_exercise_3, concept_exercise_4,
      practice_exercise_1, practice_exercise_2, practice_exercise_3, practice_exercise_4
    ], user_track.available_exercises

    assert_equal [
      concept_exercise_1,
      concept_exercise_2,
      concept_exercise_3,
      concept_exercise_4
    ], user_track.available_concept_exercises

    assert_equal [
      practice_exercise_1,
      practice_exercise_2,
      practice_exercise_3,
      practice_exercise_4
    ], user_track.available_practice_exercises
  end

  test "summary proxies correctly" do
    track = create :track
    concept = create :track_concept, track: track
    ut = create :user_track, track: track

    assert_equal concept.slug, ut.summary.concept(concept.slug).slug
  end

  test "summary is memoized" do
    ut = create :user_track
    UserTrack::GenerateSummary.expects(:call).with(ut.track, ut).returns(mock).once
    2.times { ut.summary }
  end
end
