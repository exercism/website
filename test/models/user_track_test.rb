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
    user_track = create :user_track
    assert user_track.exercise_available?(exercise)
  end

  test "exercise_available? with prerequisites" do
    exercise = create :concept_exercise
    prereq_1 = create(:exercise_prerequisite, exercise: exercise).concept
    prereq_2 = create(:exercise_prerequisite, exercise: exercise).concept
    user_track = create :user_track

    refute user_track.exercise_available?(exercise)

    create :user_track_learnt_concept, concept: prereq_1, user_track: user_track
    refute user_track.reload.exercise_available?(exercise)

    create :user_track_learnt_concept, concept: prereq_2, user_track: user_track
    assert user_track.reload.exercise_available?(exercise)
  end

  test "available exercises" do
    track = create :track
    concept_exercise_1 = create :concept_exercise, track: track
    concept_exercise_2 = create :concept_exercise, track: track
    concept_exercise_3 = create :concept_exercise, track: track
    concept_exercise_4 = create :concept_exercise, track: track

    practice_exercise_1 = create :practice_exercise, track: track
    practice_exercise_2 = create :practice_exercise, track: track
    practice_exercise_3 = create :practice_exercise, track: track
    practice_exercise_4 = create :practice_exercise, track: track

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
      practice_exercise_1,
      concept_exercise_2,
      practice_exercise_2
    ], user_track.reload.available_exercises

    assert_equal [concept_exercise_1, concept_exercise_2], user_track.available_concept_exercises
    assert_equal [practice_exercise_1, practice_exercise_2], user_track.available_practice_exercises

    # Reload the user track to override memoizing
    user_track = UserTrack.find(user_track.id)

    create :user_track_learnt_concept, concept: prereq_2, user_track: user_track
    assert_equal [
      concept_exercise_1, practice_exercise_1,
      concept_exercise_2, concept_exercise_3, concept_exercise_4,
      practice_exercise_2, practice_exercise_3, practice_exercise_4
    ], user_track.reload.available_exercises

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
end
