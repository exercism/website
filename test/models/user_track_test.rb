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
    create :hello_world_solution, :completed, track: user_track.track, user: user_track.user
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
    create :hello_world_solution, :completed, track: track, user: user_track.user
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
    create :hello_world_solution, :completed, track: track, user: user_track.user

    assert_equal [basics, recursion], user_track.unlocked_concepts
    assert_empty user_track.learnt_concepts
    assert_empty user_track.mastered_concepts
    assert user_track.concept_unlocked?(recursion)
    assert user_track.concept_unlocked?(basics)
    refute user_track.concept_unlocked?(enums)
    refute user_track.concept_unlocked?(strings)

    create :user_track_learnt_concept, user_track: user_track, concept: basics
    create :concept_solution, :completed, exercise: basics_exercise, user: user

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_equal [basics, enums, recursion], user_track.unlocked_concepts
    assert_equal [basics], user_track.learnt_concepts
    assert_empty user_track.mastered_concepts
    assert user_track.concept_unlocked?(recursion)
    assert user_track.concept_unlocked?(basics)
    assert user_track.concept_unlocked?(enums)
    refute user_track.concept_unlocked?(strings)

    create :user_track_learnt_concept, user_track: user_track, concept: enums

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_equal [basics, enums, strings, recursion], user_track.unlocked_concepts
    assert_equal [basics, enums], user_track.learnt_concepts
    assert_empty user_track.mastered_concepts
    assert user_track.concept_unlocked?(recursion)
    assert user_track.concept_unlocked?(basics)
    assert user_track.concept_unlocked?(enums)
    assert user_track.concept_unlocked?(strings)

    create :concept_solution, user: user, exercise: enums_exercise, completed_at: Time.current

    # Reload the user track to override memoizing
    user_track.reset_summary!

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
    hw_solution = create :hello_world_solution, :completed, track: track, user: user_track.user
    hello_world = hw_solution.exercise

    assert_equal [concept_exercise_1, practice_exercise_1, hello_world], user_track.unlocked_exercises
    assert_equal [concept_exercise_1], user_track.unlocked_concept_exercises
    assert_equal [practice_exercise_1, hello_world], user_track.unlocked_practice_exercises

    # Reload the user track to override memoizing
    user_track.reset_summary!

    create :user_track_learnt_concept, concept: prereq_1, user_track: user_track
    assert_equal [
      concept_exercise_1,
      concept_exercise_2,
      practice_exercise_1,
      practice_exercise_2,
      hello_world
    ], user_track.unlocked_exercises

    assert_equal [concept_exercise_1, concept_exercise_2], user_track.unlocked_concept_exercises
    assert_equal [practice_exercise_1, practice_exercise_2, hello_world], user_track.unlocked_practice_exercises

    # Reload the user track to override memoizing
    user_track.reset_summary!

    create :user_track_learnt_concept, concept: prereq_2, user_track: user_track
    assert_equal [
      concept_exercise_1, concept_exercise_2, concept_exercise_3, concept_exercise_4,
      practice_exercise_1, practice_exercise_2, practice_exercise_3, practice_exercise_4,
      hello_world
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
      practice_exercise_4,
      hello_world
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

  test "completed_percentage" do
    track = create :track
    user = create :user
    user_track = create :user_track, user: user, track: track
    exercises = Array.new(6) { create :practice_exercise, :random_slug, track: track }
    create :practice_solution, exercise: exercises[0], completed_at: Time.current, user: user

    # Don't count these
    create :practice_solution, exercise: exercises[4], user: user
    create :practice_solution, exercise: exercises[5]

    assert_equal 16.7, user_track.completed_percentage

    create :practice_solution, exercise: exercises[1], completed_at: Time.current, user: user
    create :practice_solution, exercise: exercises[2], completed_at: Time.current, user: user
    assert_equal 50, UserTrack.find(user_track.id).completed_percentage
  end

  test "tutorial_exercise_completed?" do
    track = create :track
    user = create :user
    user_track = create :user_track, user: user, track: track
    exercises = Array.new(6) { create :practice_exercise, :random_slug, track: track }

    refute user_track.tutorial_exercise_completed?

    create :practice_solution, exercise: exercises[0], completed_at: Time.current, user: user
    assert UserTrack.find(user_track.id).tutorial_exercise_completed?
  end

  test "num_xxx_exercises" do
    track = create :track
    user = create :user
    user_track = create :user_track, user: user, track: track
    exercises = Array.new(10) { create :practice_exercise, :random_slug, track: track }

    # Started
    create :practice_solution, exercise: exercises[0], user: user

    # Iterated
    ps = create :practice_solution, exercise: exercises[1], user: user
    create :iteration, solution: ps, submission: create(:submission, solution: ps)

    # Completed
    (3..6).each do |idx|
      create :practice_solution, exercise: exercises[idx], completed_at: Time.current, user: user
    end

    # Locked
    create :exercise_prerequisite, exercise: exercises[7]

    assert_equal 10, user_track.num_exercises
    assert_equal 3, user_track.num_available_exercises
    assert_equal 2, user_track.num_in_progress_exercises
    assert_equal 1, user_track.num_locked_exercises
    assert_equal 4, user_track.num_completed_exercises
  end

  test "has_notifications" do
    user = create :user
    track = create :track, :random_slug
    ut_id = create(:user_track, user: user, track: track).id

    solution = create :practice_solution, user: user, track: track
    discussion = create :mentor_discussion, solution: solution

    # Load of notifications that result in false
    create :mentor_started_discussion_notification, user: user, status: :pending
    create :mentor_started_discussion_notification, user: user, status: :unread
    create :mentor_started_discussion_notification, user: user, status: :read
    create :mentor_started_discussion_notification, user: user, status: :pending,
                                                    params: { discussion: create(:mentor_discussion, solution: solution) }
    create :mentor_started_discussion_notification, user: user, status: :read,
                                                    params: { discussion: create(:mentor_discussion, solution: solution) }
    create :mentor_started_discussion_notification, status: :unread,
                                                    params: { discussion: create(:mentor_discussion, solution: solution) }
    refute UserTrack.find(ut_id).has_notifications?

    create :mentor_started_discussion_notification, status: :unread, user: user, params: { discussion: discussion }
    assert UserTrack.find(ut_id).has_notifications?
  end

  test "active_mentoring_discussions" do
    ut = create :user_track
    assert_empty ut.active_mentoring_discussions

    disc_1 = create :mentor_discussion, :awaiting_mentor, solution: create(:concept_solution, track: ut.track, user: ut.user)
    disc_2 = create :mentor_discussion, :awaiting_student,
      solution: create(:concept_solution, track: ut.track, user: ut.user)
    disc_3 = create :mentor_discussion, :mentor_finished, solution: create(:concept_solution, track: ut.track, user: ut.user)
    create :mentor_discussion, :student_finished, solution: create(:concept_solution, track: ut.track, user: ut.user)
    create :mentor_discussion, :both_finished, solution: create(:concept_solution, track: ut.track, user: ut.user)
    assert_equal [disc_1, disc_2, disc_3], UserTrack.find(ut.id).active_mentoring_discussions
  end

  test "pending_mentoring_requests" do
    ut = create :user_track
    assert_empty ut.pending_mentoring_requests

    req = create :mentor_request, :pending, solution: create(:concept_solution, track: ut.track, user: ut.user)
    create :mentor_request, :fulfilled, solution: create(:concept_solution, track: ut.track, user: ut.user)
    create :mentor_request, :cancelled, solution: create(:concept_solution, track: ut.track, user: ut.user)
    assert_equal [req], UserTrack.find(ut.id).pending_mentoring_requests
  end
end
