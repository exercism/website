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

  test ".for handles bad data" do
    track = create :track
    ut = create :user_track, track: track
    assert_nil UserTrack.for(create(:user), nil)
    assert_nil UserTrack.for(nil, nil)
    assert_nil UserTrack.for(create(:user), track)
    assert_nil UserTrack.for(ut.user, create(:track, :random_slug))
    assert_nil UserTrack.for(nil, track)
    assert_nil UserTrack.for(nil, track.slug)

    assert_nil UserTrack.for(create(:user), nil, external_if_missing: true)
    assert_nil UserTrack.for(nil, nil, external_if_missing: true)
    assert UserTrack.for(create(:user), track, external_if_missing: true).is_a?(UserTrack::External)
    assert UserTrack.for(ut.user, create(:track, :random_slug), external_if_missing: true).is_a?(UserTrack::External)
    assert UserTrack.for(nil, track, external_if_missing: true).is_a?(UserTrack::External)
    assert UserTrack.for(nil, track.slug, external_if_missing: true).is_a?(UserTrack::External)
  end

  test "exercise_unlocked? with no prerequisites" do
    exercise = create :concept_exercise
    user_track = create :user_track, track: exercise.track
    assert user_track.exercise_unlocked?(exercise)
  end

  test "exercise_unlocked? with prerequisites" do
    track = create :track
    exercise = create :concept_exercise, :random_slug, track: track

    prereq_1 = create :track_concept, track: track
    create(:exercise_prerequisite, exercise: exercise, concept: prereq_1)

    prereq_2 = create :track_concept, track: track
    create(:exercise_prerequisite, exercise: exercise, concept: prereq_2)

    user_track = create :user_track, track: track
    refute user_track.exercise_unlocked?(exercise)

    create :user_track_learnt_concept, concept: prereq_1, user_track: user_track
    user_track.reset_summary!
    refute UserTrack.find(user_track.id).exercise_unlocked?(exercise)

    create :user_track_learnt_concept, concept: prereq_2, user_track: user_track
    user_track.reset_summary!
    assert UserTrack.find(user_track.id).exercise_unlocked?(exercise)
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

    assert_equal [basics, recursion], user_track.unlocked_concepts
    assert_empty user_track.learnt_concepts
    assert_empty user_track.mastered_concepts
    assert user_track.concept_unlocked?(recursion)
    assert user_track.concept_unlocked?(basics)
    refute user_track.concept_unlocked?(enums)
    refute user_track.concept_unlocked?(strings)

    # Reload the user track to override memoizing
    user_track.reset_summary!

    create :user_track_learnt_concept, user_track: user_track, concept: basics

    assert_equal [basics, enums, recursion], user_track.unlocked_concepts
    assert_equal [basics], user_track.learnt_concepts
    assert_empty user_track.mastered_concepts
    assert user_track.concept_unlocked?(recursion)
    assert user_track.concept_unlocked?(basics)
    assert user_track.concept_unlocked?(enums)
    refute user_track.concept_unlocked?(strings)

    # Reload the user track to override memoizing
    user_track.reset_summary!

    create :user_track_learnt_concept, user_track: user_track, concept: enums

    assert_equal [basics, enums, strings, recursion], user_track.unlocked_concepts
    assert_equal [basics, enums], user_track.learnt_concepts
    assert_empty user_track.mastered_concepts
    assert user_track.concept_unlocked?(recursion)
    assert user_track.concept_unlocked?(basics)
    assert user_track.concept_unlocked?(enums)
    assert user_track.concept_unlocked?(strings)

    # Reload the user track to override memoizing
    user_track.reset_summary!

    create :concept_solution, user: user, exercise: enums_exercise, completed_at: Time.current
    assert_equal [basics, enums, strings, recursion], user_track.unlocked_concepts
    assert_equal [basics, enums], user_track.learnt_concepts
    assert_equal [enums], user_track.mastered_concepts

    # TODO: Add test for practices exercise
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

    assert_equal [concept_exercise_1, practice_exercise_1], user_track.unlocked_exercises
    assert_equal [concept_exercise_1], user_track.unlocked_concept_exercises
    assert_equal [practice_exercise_1], user_track.unlocked_practice_exercises

    # Reload the user track to override memoizing
    user_track.reset_summary!

    create :user_track_learnt_concept, concept: prereq_1, user_track: user_track
    assert_equal [
      concept_exercise_1,
      concept_exercise_2,
      practice_exercise_1,
      practice_exercise_2
    ], user_track.unlocked_exercises

    assert_equal [concept_exercise_1, concept_exercise_2], user_track.unlocked_concept_exercises
    assert_equal [practice_exercise_1, practice_exercise_2], user_track.unlocked_practice_exercises

    # Reload the user track to override memoizing
    user_track.reset_summary!

    create :user_track_learnt_concept, concept: prereq_2, user_track: user_track
    assert_equal [
      concept_exercise_1, concept_exercise_2, concept_exercise_3, concept_exercise_4,
      practice_exercise_1, practice_exercise_2, practice_exercise_3, practice_exercise_4
    ], user_track.unlocked_exercises

    assert_equal [
      concept_exercise_1,
      concept_exercise_2,
      concept_exercise_3,
      concept_exercise_4
    ], user_track.unlocked_concept_exercises

    assert_equal [
      practice_exercise_1,
      practice_exercise_2,
      practice_exercise_3,
      practice_exercise_4
    ], user_track.unlocked_practice_exercises
  end

  test "in_progress_exercises" do
    track = create :track
    concept_exercise_1 = create :concept_exercise, :random_slug, track: track
    concept_exercise_2 = create :concept_exercise, :random_slug, track: track

    practice_exercise_1 = create :practice_exercise, :random_slug, track: track
    create :practice_exercise, :random_slug, track: track

    user = create :user
    user_track = create :user_track, track: track, user: user

    create :concept_solution, user: user, exercise: concept_exercise_1, completed_at: Time.current
    create :concept_solution, user: user, exercise: concept_exercise_2
    create :practice_solution, user: user, exercise: practice_exercise_1

    assert_equal [concept_exercise_2, practice_exercise_1], user_track.in_progress_exercises
  end

  test "completed_exercises" do
    track = create :track
    exercise_1 = create :concept_exercise, :random_slug, track: track
    exercise_2 = create :concept_exercise, :random_slug, track: track

    user = create :user
    user_track = create :user_track, track: track, user: user

    create :concept_solution, user: user, exercise: exercise_1, completed_at: Time.current
    create :concept_solution, user: user, exercise: exercise_2

    assert_equal [exercise_1], user_track.completed_exercises
  end

  test "summary proxies correctly" do
    track = create :track
    concept = create :track_concept, track: track
    ut = create :user_track, track: track

    assert_equal concept.slug, ut.send(:summary).concept(concept.slug).slug
  end

  test "summary is memoized" do
    ut = create :user_track
    UserTrack::Summary.expects(:new).returns(mock).once
    2.times { ut.send(:summary) }
  end

  test "summary is regenerated correctly" do
    summary = { concepts: {}, exercises: {} }
    ut = create(:user_track)
    ut.send(:summary)
    track = ut.track

    track.update_column(:updated_at, Time.current + 1.day)
    ut = UserTrack.find(ut.id)
    UserTrack::GenerateSummaryData.expects(:call).with(track, ut).returns(summary)
    ut.send(:summary)

    ut.update_column(:updated_at, Time.current + 1.day)
    ut = UserTrack.find(ut.id)
    UserTrack::GenerateSummaryData.expects(:call).with(track, ut).returns(summary)
    ut.send(:summary)

    # Shouldn't require another generate user summary data
    ut.send(:summary)
  end

  test "solutions" do
    user = create :user
    track = create :track, slug: :js
    user_track = create :user_track, user: user, track: track

    s_1 = create :concept_solution, user: user, exercise: create(:concept_exercise, track: track)
    s_2 = create :practice_solution, user: user, exercise: create(:practice_exercise, track: track)
    create :concept_solution, exercise: create(:concept_exercise, track: track)
    create :concept_solution, user: user

    assert_equal [s_1, s_2], user_track.solutions
  end
end
