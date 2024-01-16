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
    ut = create(:user_track, track:)

    assert_nil UserTrack.for(create(:user), nil)
    assert_nil UserTrack.for(nil, nil)
    assert UserTrack.for(create(:user), track).is_a?(UserTrack::External)
    assert UserTrack.for(ut.user, create(:track, :random_slug)).is_a?(UserTrack::External)
    assert UserTrack.for(nil, track).is_a?(UserTrack::External)
    assert UserTrack.for(nil, track.slug).is_a?(UserTrack::External)
  end

  test "touching only changes updated_at" do
    user_track = freeze_time { create :user_track }
    original_time = user_track.updated_at

    travel 1.day do
      user_track.touch
      assert_equal Time.current, user_track.updated_at
      assert_equal original_time, user_track.last_touched_at
    end
  end

  test "updating solution updates last_touched_at and updated_at" do
    track = create :track
    user = create :user
    user_track = create(:user_track, user:, track:)

    solution = nil

    travel 1.day do
      solution = create(:concept_solution, user:, track:)
      user_track.reload
      assert_equal Time.current, user_track.updated_at
      assert_equal Time.current, user_track.last_touched_at
    end

    travel 2.days do
      solution.update(status: "published")
      user_track.reload
      assert_equal Time.current, user_track.updated_at
      assert_equal Time.current, user_track.last_touched_at
    end
  end

  test "exercise_unlocked? with no prerequisites" do
    exercise = create :concept_exercise
    user_track = create :user_track, track: exercise.track
    create :hello_world_solution, :completed, track: user_track.track, user: user_track.user
    assert user_track.exercise_unlocked?(exercise)
  end

  test "exercise_unlocked? ignores prerequisites taught by wip exercises" do
    user = create :user
    track = create :track
    concept_1 = create(:concept, track:)
    concept_2 = create(:concept, track:)
    concept_3 = create(:concept, track:)
    active_exercise = create :concept_exercise, :random_slug, track:, status: :active
    beta_exercise = create :concept_exercise, :random_slug, track:, status: :beta
    wip_exercise = create :concept_exercise, :random_slug, track:, status: :wip
    active_exercise.taught_concepts << concept_1
    beta_exercise.taught_concepts << concept_2
    beta_exercise.prerequisites << concept_1
    wip_exercise.taught_concepts << concept_3
    practice_exercise = create(:practice_exercise, :random_slug, track:)
    practice_exercise.prerequisites = [concept_1, concept_2, concept_3]
    user_track = create(:user_track, track:, user:)
    create(:hello_world_solution, :completed, track:, user:)

    # Sanity check
    assert user_track.exercise_unlocked?(active_exercise)
    refute user_track.exercise_unlocked?(beta_exercise)
    refute user_track.exercise_unlocked?(practice_exercise)

    create :concept_solution, :completed, user:, exercise: active_exercise
    create :concept_solution, :completed, user:, exercise: beta_exercise

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert user_track.exercise_unlocked?(active_exercise)
    assert user_track.exercise_unlocked?(beta_exercise)
    assert user_track.exercise_unlocked?(practice_exercise)
  end

  test "unlocked exercises" do
    track = create :track
    concept_exercise_1 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_2 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_3 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_4 = create(:concept_exercise, :random_slug, track:)

    practice_exercise_1 = create(:practice_exercise, :random_slug, track:)
    practice_exercise_2 = create(:practice_exercise, :random_slug, track:)
    practice_exercise_3 = create(:practice_exercise, :random_slug, track:)
    practice_exercise_4 = create(:practice_exercise, :random_slug, track:)

    prereq_1 = create(:concept, track:)
    prereq_2 = create(:concept, track:)

    concept_exercise_1.taught_concepts << prereq_1
    concept_exercise_1.taught_concepts << prereq_2

    create(:exercise_prerequisite, exercise: concept_exercise_2, concept: prereq_1)
    create(:exercise_prerequisite, exercise: practice_exercise_2, concept: prereq_1)
    create(:exercise_prerequisite, exercise: concept_exercise_3, concept: prereq_1)
    create(:exercise_prerequisite, exercise: practice_exercise_3, concept: prereq_1)
    create(:exercise_prerequisite, exercise: concept_exercise_3, concept: prereq_2)
    create(:exercise_prerequisite, exercise: practice_exercise_3, concept: prereq_2)
    create(:exercise_prerequisite, exercise: concept_exercise_4, concept: prereq_2)
    create(:exercise_prerequisite, exercise: practice_exercise_4, concept: prereq_2)
    user = create :user
    user_track = create(:user_track, track:, user:)
    hw_solution = create(:hello_world_solution, :completed, track:, user:)
    hello_world = hw_solution.exercise

    assert_equal [concept_exercise_1, practice_exercise_1, hello_world], user_track.unlocked_exercises
    assert_equal [concept_exercise_1], user_track.unlocked_concept_exercises
    assert_equal [practice_exercise_1, hello_world], user_track.unlocked_practice_exercises

    concept_exercise_5 = create(:concept_exercise, slug: 'pr1-ex', track:)
    concept_exercise_5.taught_concepts << prereq_1
    create :concept_solution, :completed, user:, exercise: concept_exercise_5

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_equal [
      concept_exercise_1,
      concept_exercise_2,
      practice_exercise_1,
      practice_exercise_2,
      hello_world,
      concept_exercise_5
    ], user_track.unlocked_exercises

    assert_equal [concept_exercise_1, concept_exercise_2, concept_exercise_5], user_track.unlocked_concept_exercises
    assert_equal [practice_exercise_1, practice_exercise_2, hello_world], user_track.unlocked_practice_exercises

    concept_exercise_6 = create(:concept_exercise, slug: 'pr2-ex', track:)
    concept_exercise_6.taught_concepts << prereq_2
    create :concept_solution, :completed, user:, exercise: concept_exercise_6

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_equal [
      concept_exercise_1, concept_exercise_2, concept_exercise_3, concept_exercise_4,
      practice_exercise_1, practice_exercise_2, practice_exercise_3, practice_exercise_4,
      hello_world,
      concept_exercise_5, concept_exercise_6
    ], user_track.unlocked_exercises

    assert_equal [
      concept_exercise_1, concept_exercise_2, concept_exercise_3, concept_exercise_4,
      concept_exercise_5, concept_exercise_6
    ], user_track.unlocked_concept_exercises

    assert_equal [
      practice_exercise_1,
      practice_exercise_2,
      practice_exercise_3,
      practice_exercise_4,
      hello_world
    ], user_track.unlocked_practice_exercises
  end

  test "all exercises are unlocked for admins" do
    track = create :track
    concept_exercise_1 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_2 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_3 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_4 = create(:concept_exercise, :random_slug, track:)

    practice_exercise_1 = create(:practice_exercise, :random_slug, track:)
    practice_exercise_2 = create(:practice_exercise, :random_slug, track:)
    practice_exercise_3 = create(:practice_exercise, :random_slug, track:)
    practice_exercise_4 = create(:practice_exercise, :random_slug, track:)

    prereq_1 = create(:concept, track:)
    prereq_2 = create(:concept, track:)

    concept_exercise_1.taught_concepts << prereq_1
    concept_exercise_1.taught_concepts << prereq_2

    create(:exercise_prerequisite, exercise: concept_exercise_2, concept: prereq_1)
    create(:exercise_prerequisite, exercise: practice_exercise_2, concept: prereq_1)
    create(:exercise_prerequisite, exercise: concept_exercise_3, concept: prereq_1)
    create(:exercise_prerequisite, exercise: practice_exercise_3, concept: prereq_1)
    create(:exercise_prerequisite, exercise: concept_exercise_3, concept: prereq_2)
    create(:exercise_prerequisite, exercise: practice_exercise_3, concept: prereq_2)
    create(:exercise_prerequisite, exercise: concept_exercise_4, concept: prereq_2)
    create(:exercise_prerequisite, exercise: practice_exercise_4, concept: prereq_2)
    hello_world = create(:hello_world_exercise, track:)

    user = create :user, roles: [:admin]
    user_track = create(:user_track, track:, user:)

    assert_equal [
      concept_exercise_1, concept_exercise_2, concept_exercise_3, concept_exercise_4,
      practice_exercise_1, practice_exercise_2, practice_exercise_3, practice_exercise_4,
      hello_world
    ], user_track.unlocked_exercises

    assert_equal [
      concept_exercise_1, concept_exercise_2, concept_exercise_3, concept_exercise_4
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
    concept_exercise_1 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_2 = create(:concept_exercise, :random_slug, track:)

    practice_exercise_1 = create(:practice_exercise, :random_slug, track:)
    create(:practice_exercise, :random_slug, track:)

    user = create :user
    user_track = create(:user_track, track:, user:)

    create :concept_solution, user:, exercise: concept_exercise_1, completed_at: Time.current
    create :concept_solution, user:, exercise: concept_exercise_2
    create :practice_solution, user:, exercise: practice_exercise_1

    assert_equal [concept_exercise_2, practice_exercise_1], user_track.in_progress_exercises
  end

  test "completed_exercises" do
    track = create :track
    exercise_1 = create(:concept_exercise, :random_slug, track:)
    exercise_2 = create(:concept_exercise, :random_slug, track:)

    user = create :user
    user_track = create(:user_track, track:, user:)

    create :concept_solution, user:, exercise: exercise_1, completed_at: Time.current
    create :concept_solution, user:, exercise: exercise_2

    assert_equal [exercise_1], user_track.completed_exercises
  end

  test "summary proxies correctly" do
    track = create :track
    concept = create(:concept, track:)
    ut = create(:user_track, track:)

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

    ut.update_column(:last_touched_at, Time.current + 1.day)
    ut = UserTrack.find(ut.id)
    UserTrack::GenerateSummaryData.expects(:call).with(track, ut).returns(summary)
    ut.send(:summary)

    # Shouldn't require another generate user summary data
    UserTrack::GenerateSummaryData.expects(:call).never
    ut.send(:summary)
  end

  test "solutions" do
    user = create :user
    track = create :track, slug: :js
    user_track = create(:user_track, user:, track:)

    s_1 = create :concept_solution, user:, exercise: create(:concept_exercise, track:)
    s_2 = create :practice_solution, user:, exercise: create(:practice_exercise, track:)
    create :concept_solution, exercise: create(:concept_exercise, track:)
    create(:concept_solution, user:)

    assert_equal [s_1, s_2], user_track.solutions
  end

  test "completed_percentage" do
    track = create :track
    user = create :user
    user_track = create(:user_track, user:, track:)
    exercises = Array.new(6) { create(:practice_exercise, :random_slug, track:) }
    create(:practice_solution, exercise: exercises[0], completed_at: Time.current, user:)

    # Don't count these
    create(:practice_solution, exercise: exercises[4], user:)
    create :practice_solution, exercise: exercises[5]

    assert_equal 16.7, user_track.completed_percentage

    create(:practice_solution, exercise: exercises[1], completed_at: Time.current, user:)
    create(:practice_solution, exercise: exercises[2], completed_at: Time.current, user:)
    assert_equal 50, UserTrack.find(user_track.id).completed_percentage
  end

  test "completed_concept_exercises_percentage" do
    track = create :track
    user = create :user
    user_track = create(:user_track, user:, track:)
    exercises = Array.new(6) { create(:concept_exercise, :random_slug, track:) }
    create(:concept_solution, exercise: exercises[0], completed_at: Time.current, user:)
    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_2 = create(:practice_exercise, :random_slug, track:)

    # Don't count these
    create(:concept_solution, exercise: exercises[4], user:)
    create :concept_solution, exercise: exercises[5]
    create :practice_solution, exercise: pe_1
    create :practice_solution, :completed, exercise: pe_2

    assert_equal 16.7, user_track.completed_concept_exercises_percentage

    create(:concept_solution, exercise: exercises[1], completed_at: Time.current, user:)
    create(:concept_solution, exercise: exercises[2], completed_at: Time.current, user:)
    assert_equal 50, UserTrack.find(user_track.id).completed_concept_exercises_percentage
  end

  test "tutorial_exercise_completed?" do
    track = create :track
    user = create :user
    user_track = create(:user_track, user:, track:)
    exercises = Array.new(6) { create(:practice_exercise, :random_slug, track:) }

    refute user_track.tutorial_exercise_completed?

    create(:practice_solution, exercise: exercises[0], completed_at: Time.current, user:)
    assert UserTrack.find(user_track.id).tutorial_exercise_completed?
  end

  test "num_xxx_exercises" do
    track = create :track
    user = create :user
    concept = create(:concept, track:)
    another_concept = create :concept, track:, slug: 'dates'
    concept_exercise = create(:concept_exercise, track:)
    concept_exercise.taught_concepts << concept
    another_concept_exercise = create :concept_exercise, track:, slug: 'daring-dates'
    another_concept_exercise.taught_concepts << another_concept
    user_track = create(:user_track, user:, track:)
    exercises = Array.new(10) { create(:practice_exercise, :random_slug, track:) }
    exercises << concept_exercise

    # Started
    create(:practice_solution, exercise: exercises[0], user:)

    # Iterated
    ps = create(:practice_solution, exercise: exercises[1], user:)
    create :iteration, solution: ps, submission: create(:submission, solution: ps)

    # Completed
    (3..6).each do |idx|
      create :practice_solution, exercise: exercises[idx], completed_at: Time.current, user:
    end

    create(:concept_solution, exercise: another_concept_exercise, completed_at: Time.current, user:)

    # Locked
    exercises[7].prerequisites << concept

    assert_equal 12, user_track.num_exercises
    assert_equal 2, user_track.num_concept_exercises
    assert_equal 4, user_track.num_available_exercises
    assert_equal 2, user_track.num_in_progress_exercises
    assert_equal 1, user_track.num_locked_exercises
    assert_equal 5, user_track.num_completed_exercises
    assert_equal 1, user_track.num_completed_concept_exercises
  end

  test "num_xxx_concepts" do
    track = create :track
    user = create :user
    user_track = create(:user_track, user:, track:)

    c_1 = create :concept, track:, slug: "strings"
    c_2 = create :concept, track:, slug: "numbers"
    c_3 = create :concept, track:, slug: "dates"
    c_4 = create :concept, track:, slug: "classes"
    c_5 = create :concept, track:, slug: "inheritance"

    practice_exercises = Array.new(10) { create(:practice_exercise, :random_slug, track:) }
    concept_exercises = Array.new(5) { create(:concept_exercise, :random_slug, track:) }

    concept_exercises[0].taught_concepts << c_1
    concept_exercises[1].taught_concepts << c_2
    concept_exercises[2].taught_concepts << c_3
    concept_exercises[3].taught_concepts << c_4

    concept_exercises[1].prerequisites << c_1
    concept_exercises[2].prerequisites << c_2
    concept_exercises[4].prerequisites << c_3
    concept_exercises[4].prerequisites << c_4

    practice_exercises[1].prerequisites << c_1
    practice_exercises[1].prerequisites << c_3
    practice_exercises[2].prerequisites << c_2
    practice_exercises[3].prerequisites << c_3
    practice_exercises[4].prerequisites << c_5

    user_track.reload

    assert_equal 4, user_track.num_concepts
    assert_equal 0, user_track.num_concepts_learnt
    assert_equal 0, user_track.num_concepts_mastered

    # Started
    create(:practice_solution, exercise: practice_exercises[0], user:)

    # Iterated
    ps = create(:practice_solution, exercise: practice_exercises[1], user:)
    create :iteration, solution: ps, submission: create(:submission, solution: ps)

    # Completed
    create(:practice_solution, exercise: practice_exercises[2], completed_at: Time.current, user:)
    create(:concept_solution, exercise: concept_exercises[0], completed_at: Time.current, user:)
    create(:concept_solution, exercise: concept_exercises[3], completed_at: Time.current, user:)

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_equal 4, user_track.num_concepts
    assert_equal 2, user_track.num_concepts_learnt
    assert_equal 2, user_track.num_concepts_mastered
  end

  test "completed?" do
    track = create :track
    user = create :user
    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_2 = create(:concept_exercise, :random_slug, track:)
    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_2 = create(:practice_exercise, :random_slug, track:)
    user_track = create(:user_track, user:, track:)

    # Started
    ps_1 = create(:practice_solution, exercise: pe_1, user:)

    # Iterated
    ps_2 = create(:practice_solution, exercise: pe_2, user:)
    cs_3 = create(:concept_solution, exercise: ce_1, user:)

    # Completed
    create(:concept_solution, exercise: ce_2, completed_at: Time.current, user:)

    refute user_track.completed?
    refute user_track.completed_course?

    cs_3.update(completed_at: Time.current)
    user_track.reset_summary!

    refute user_track.completed?
    assert user_track.completed_course?

    ps_1.update(completed_at: Time.current)
    ps_2.update(completed_at: Time.current)
    user_track.reset_summary!

    assert user_track.completed?
    assert user_track.completed_course?
  end

  test "has_notifications" do
    user = create :user
    track = create :track, :random_slug
    ut_id = create(:user_track, user:, track:).id

    solution = create(:practice_solution, user:, track:)
    discussion = create(:mentor_discussion, solution:)

    # Load of notifications that result in false
    create :mentor_started_discussion_notification, user:, status: :pending
    create :mentor_started_discussion_notification, user:, status: :unread
    create :mentor_started_discussion_notification, user:, status: :read
    create :mentor_started_discussion_notification, user:, status: :pending,
      params: { discussion: create(:mentor_discussion, solution:) }
    create :mentor_started_discussion_notification, user:, status: :read,
      params: { discussion: create(:mentor_discussion, solution:) }
    create :mentor_started_discussion_notification, status: :unread,
      params: { discussion: create(:mentor_discussion, solution:) }
    refute UserTrack.find(ut_id).has_notifications?

    create :mentor_started_discussion_notification, status: :unread, user:, params: { discussion: }
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

  test "exercises" do
    track = create :track
    user = create :user
    user_track = create(:user_track, track:, user:)

    create :concept_exercise, :random_slug, track:, status: :wip, slug: 'ce_wip'
    beta_concept_exercise = create :concept_exercise, :random_slug, track:, status: :beta, slug: 'ce_beta'
    active_concept_exercise = create :concept_exercise, :random_slug, track:, status: :active, slug: 'ce_active'
    create :concept_exercise, :random_slug, track:, status: :deprecated, slug: 'ce_deprecated'

    create :practice_exercise, :random_slug, track:, status: :wip, slug: 'pe_wip'
    beta_practice_exercise = create :practice_exercise, :random_slug, track:, status: :beta, slug: 'pe_beta'
    active_practice_exercise = create :practice_exercise, :random_slug, track:, status: :active, slug: 'pe_active'
    create :practice_exercise, :random_slug, track:, status: :deprecated, slug: 'pe_deprecated'

    # wip exercises and unstarted deprecated exercises are not included
    assert_equal [
      beta_concept_exercise,
      active_concept_exercise,
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.exercises.map(&:slug).sort
  end

  test "exercises includes deprecated exercises that the user started" do
    track = create :track
    user = create :user
    user_track = create(:user_track, track:, user:)

    create :concept_exercise, :random_slug, track:, status: :wip, slug: 'ce_wip'
    beta_concept_exercise = create :concept_exercise, :random_slug, track:, status: :beta, slug: 'ce_beta'
    active_concept_exercise = create :concept_exercise, :random_slug, track:, status: :active, slug: 'ce_active'
    deprecated_concept_exercise = create :concept_exercise, :random_slug, track:, status: :deprecated, slug: 'ce_deprecated'

    create :practice_exercise, :random_slug, track:, status: :wip, slug: 'pe_wip'
    beta_practice_exercise = create :practice_exercise, :random_slug, track:, status: :beta, slug: 'pe_beta'
    active_practice_exercise = create :practice_exercise, :random_slug, track:, status: :active, slug: 'pe_active'
    deprecated_practice_exercise = create :practice_exercise, :random_slug, track:, status: :deprecated, slug: 'pe_deprecated'

    create :concept_solution, user:, exercise: deprecated_concept_exercise
    create :practice_solution, user:, exercise: deprecated_practice_exercise

    assert_equal [
      beta_concept_exercise,
      active_concept_exercise,
      deprecated_concept_exercise,
      beta_practice_exercise,
      active_practice_exercise,
      deprecated_practice_exercise
    ].map(&:slug).sort, user_track.exercises.map(&:slug).sort
  end

  test "exercises includes wip exercise for track maintainer" do
    track = create :track
    user = create :user, :maintainer, uid: '264713'
    user_track = create(:user_track, track:, user:)

    wip_concept_exercise = create :concept_exercise, :random_slug, track:, status: :wip, slug: 'ce_wip'
    beta_concept_exercise = create :concept_exercise, :random_slug, track:, status: :beta, slug: 'ce_beta'
    active_concept_exercise = create :concept_exercise, :random_slug, track:, status: :active, slug: 'ce_active'
    create :concept_exercise, :random_slug, track:, status: :deprecated, slug: 'ce_deprecated'

    wip_practice_exercise = create :practice_exercise, :random_slug, track:, status: :wip, slug: 'pe_wip'
    beta_practice_exercise = create :practice_exercise, :random_slug, track:, status: :beta, slug: 'pe_beta'
    active_practice_exercise = create :practice_exercise, :random_slug, track:, status: :active, slug: 'pe_active'
    create :practice_exercise, :random_slug, track:, status: :deprecated, slug: 'pe_deprecated'

    # wip exercises are not included
    # concept exercises are included when track has course
    track.update(course: true)
    assert_equal [
      beta_concept_exercise,
      active_concept_exercise,
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.reload.exercises.map(&:slug).sort

    # concept exercises are not included when track does not have course
    track.update(course: false)
    assert_equal [
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.reload.exercises.map(&:slug).sort

    create :github_team_member, user_id: user.uid, team_name: track.github_team_name

    # wip and concept exercises are included when user is track maintainer
    assert_equal [
      wip_concept_exercise,
      beta_concept_exercise,
      active_concept_exercise,
      wip_practice_exercise,
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.reload.exercises.map(&:slug).sort
  end

  test "concept_exercises" do
    track = create :track
    user = create :user
    user_track = create(:user_track, track:, user:)

    wip_concept_exercise = create :concept_exercise, :random_slug, track:, status: :wip, slug: 'ce_wip'
    beta_concept_exercise = create :concept_exercise, :random_slug, track:, status: :beta, slug: 'ce_beta'
    active_concept_exercise = create :concept_exercise, :random_slug, track:, status: :active, slug: 'ce_active'
    create :concept_exercise, :random_slug, track:, status: :deprecated, slug: 'ce_deprecated'

    # Sanity check: practice exercise should not be included
    create(:practice_exercise, :random_slug, track:)

    # wip exercises and unstarted deprecated exercises are not included
    track.update(course: true)
    assert_equal [
      beta_concept_exercise,
      active_concept_exercise
    ].map(&:slug).sort, user_track.reload.concept_exercises.map(&:slug).sort

    # Sanity check: concept exercises not included for track without course
    track.update(course: false)
    assert_empty user_track.reload.concept_exercises.map(&:slug).sort

    # Sanity check: concept exercises are included for track without course but user is track maintainer
    user.update(roles: [:maintainer], uid: '21312312')
    create :github_team_member, user_id: user.uid, team_name: track.github_team_name
    assert_equal [
      beta_concept_exercise,
      active_concept_exercise,
      wip_concept_exercise
    ].map(&:slug).sort, user_track.reload.concept_exercises.map(&:slug).sort
  end

  test "concept_exercises includes deprecated concept exercises that the user started" do
    track = create :track
    user = create :user
    user_track = create(:user_track, track:, user:)

    create :concept_exercise, :random_slug, track:, status: :wip, slug: 'ce_wip'
    beta_concept_exercise = create :concept_exercise, :random_slug, track:, status: :beta, slug: 'ce_beta'
    active_concept_exercise = create :concept_exercise, :random_slug, track:, status: :active, slug: 'ce_active'
    deprecated_concept_exercise = create :concept_exercise, :random_slug, track:, status: :deprecated, slug: 'ce_deprecated'

    create :concept_solution, user:, exercise: deprecated_concept_exercise

    # Sanity check: practice exercise should not be included
    create(:practice_exercise, :random_slug, track:)

    assert_equal [
      beta_concept_exercise,
      active_concept_exercise,
      deprecated_concept_exercise
    ].map(&:slug).sort, user_track.concept_exercises.map(&:slug).sort
  end

  test "practice_exercises" do
    track = create :track
    user = create :user
    user_track = create(:user_track, track:, user:)

    create :practice_exercise, :random_slug, track:, status: :wip, slug: 'pe_wip'
    beta_practice_exercise = create :practice_exercise, :random_slug, track:, status: :beta, slug: 'pe_beta'
    active_practice_exercise = create :practice_exercise, :random_slug, track:, status: :active, slug: 'pe_active'
    create :practice_exercise, :random_slug, track:, status: :deprecated, slug: 'pe_deprecated'

    # Sanity check: concept exercise should not be included
    create(:concept_exercise, :random_slug, track:)

    # wip exercises and unstarted deprecated practice exercises are not included
    track.update(course: true)
    assert_equal [
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.reload.practice_exercises.map(&:slug).sort

    # practice exercises are included when track does not have course
    track.update(course: false)
    assert_equal [
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.reload.practice_exercises.map(&:slug).sort
  end

  test "practice_exercises includes deprecated practice exercises that the user started" do
    track = create :track
    user = create :user
    user_track = create(:user_track, track:, user:)

    create :practice_exercise, :random_slug, track:, status: :wip, slug: 'pe_wip'
    beta_practice_exercise = create :practice_exercise, :random_slug, track:, status: :beta, slug: 'pe_beta'
    active_practice_exercise = create :practice_exercise, :random_slug, track:, status: :active, slug: 'pe_active'
    deprecated_practice_exercise = create :practice_exercise, :random_slug, track:, status: :deprecated, slug: 'pe_deprecated'

    create :practice_solution, user:, exercise: deprecated_practice_exercise

    # Sanity check: concept exercise should not be included
    create(:concept_exercise, :random_slug, track:)

    assert_equal [
      beta_practice_exercise,
      active_practice_exercise,
      deprecated_practice_exercise
    ].map(&:slug).sort, user_track.practice_exercises.map(&:slug).sort
  end

  test "concept_exercises_for_concept" do
    track = create :track
    user = create :user
    user_track = create(:user_track, track:, user:)

    c_1 = create :concept, track:, slug: "strings"
    c_2 = create :concept, track:, slug: "numbers"

    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_1.taught_concepts << c_1

    ce_2 = create(:concept_exercise, :random_slug, track:)
    ce_2.taught_concepts << c_1
    ce_2.prerequisites << c_2

    # Sanity check: don't include concept exercise with different concept
    ce_3 = create(:concept_exercise, :random_slug, track:)
    ce_3.taught_concepts << c_2

    # Sanity check: don't include concept exercise exercise that has concept as prerequisite
    ce_4 = create(:concept_exercise, :random_slug, track:)
    ce_4.prerequisites << c_1

    # Sanity check: don't include concept exercise without taught concept
    ce_5 = create(:concept_exercise, :random_slug, track:)
    ce_5.taught_concepts = []

    # Sanity check: don't include practice exercises
    create(:practice_exercise, :random_slug, track:)
    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_1.practiced_concepts << c_1

    expected = [ce_1, ce_2].map(&:slug).sort
    assert_equal expected, user_track.concept_exercises_for_concept(c_1).map(&:slug).sort
  end

  test "practice_exercises_for_concept" do
    track = create :track
    user = create :user
    user_track = create(:user_track, track:, user:)

    c_1 = create :concept, track:, slug: "strings"
    c_2 = create :concept, track:, slug: "numbers"

    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_1.practiced_concepts << c_1

    pe_2 = create(:practice_exercise, :random_slug, track:)
    pe_2.practiced_concepts << c_1
    pe_2.practiced_concepts << c_2

    # Sanity check: don't include practice exercise with different concept
    pe_3 = create(:practice_exercise, :random_slug, track:)
    pe_3.practiced_concepts << c_2

    # Sanity check: don't include practice exercise that has concept as prerequisite
    pe_4 = create(:practice_exercise, :random_slug, track:)
    pe_4.prerequisites << c_1

    # Sanity check: don't include practice exercise without practiced concept
    pe_5 = create(:practice_exercise, :random_slug, track:)
    pe_5.practiced_concepts = []

    # Sanity check: don't include concept exercises
    create(:concept_exercise, :random_slug, track:)
    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_1.taught_concepts << c_1

    expected = [pe_1, pe_2].map(&:slug).sort
    assert_equal expected, user_track.practice_exercises_for_concept(c_1).map(&:slug).sort
  end

  test "unlocked_exercises_for_exercise" do
    track = create :track
    basics = create :concept, track:, slug: "co_basics"
    enums = create :concept, track:, slug: "co_enums"
    strings = create :concept, track:, slug: "co_strings"
    extensions = create :concept, track:, slug: "co_extensions"

    # Nothing teaches recursion
    create :concept, track:, slug: "co_recursion"

    basics_exercise = create(:concept_exercise, slug: "ex_basics", track:)
    basics_exercise.taught_concepts << basics

    enums_exercise = create(:concept_exercise, slug: "ex_enums", track:)
    enums_exercise.prerequisites << basics
    enums_exercise.taught_concepts << enums

    strings_exercise = create(:concept_exercise, slug: "ex_strings", track:)
    strings_exercise.prerequisites << enums
    strings_exercise.prerequisites << basics
    strings_exercise.taught_concepts << strings

    extensions_exercise = create :concept_exercise, slug: "ex_extensions", track:, status: :deprecated
    extensions_exercise.prerequisites << strings
    extensions_exercise.taught_concepts << extensions

    practice_exercise = create(:practice_exercise, slug: "ex_prac_enums", track:)
    practice_exercise.prerequisites << enums
    practice_exercise.practiced_concepts << enums

    user = create :user
    user_track = create(:user_track, track:, user:)
    create :hello_world_solution, :completed, track:, user: user_track.user

    # The basics exercise has not been completed so no unlocked exercises
    assert_empty user_track.unlocked_exercises_for_exercise(basics_exercise)

    # Completing the basics exercise unlocks the enums exercise
    create(:concept_solution, :completed, exercise: basics_exercise, user:)

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_equal [enums_exercise], user_track.unlocked_exercises_for_exercise(basics_exercise)

    # Completing the enums exercise unlocks the strings exercise
    create(:concept_solution, :completed, exercise: enums_exercise, user:)

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_equal [strings_exercise, practice_exercise], user_track.unlocked_exercises_for_exercise(enums_exercise)
    assert_equal [enums_exercise, strings_exercise], user_track.unlocked_exercises_for_exercise(basics_exercise)

    # Completing the strings exercise should normally unlock the extensions exercise,
    # but it shouldn't because that exercise is deprecated
    create(:concept_solution, :completed, exercise: strings_exercise, user:)

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_empty user_track.unlocked_exercises_for_exercise(strings_exercise)
    assert_equal [strings_exercise, practice_exercise], user_track.unlocked_exercises_for_exercise(enums_exercise)
    assert_equal [enums_exercise, strings_exercise], user_track.unlocked_exercises_for_exercise(basics_exercise)
  end

  test "unlocked_concepts_for_exercise" do
    track = create :track
    basics = create :concept, track:, slug: "co_basics"
    enums = create :concept, track:, slug: "co_enums"
    strings = create :concept, track:, slug: "co_strings"

    # Nothing teaches recursion
    create :concept, track:, slug: "co_recursion"

    basics_exercise = create(:concept_exercise, slug: "ex_basics", track:)
    basics_exercise.taught_concepts << basics

    enums_exercise = create(:concept_exercise, slug: "ex_enums", track:)
    enums_exercise.prerequisites << basics
    enums_exercise.taught_concepts << enums

    strings_exercise = create(:concept_exercise, slug: "ex_strings", track:)
    strings_exercise.prerequisites << enums
    strings_exercise.prerequisites << basics
    strings_exercise.taught_concepts << strings

    practice_exercise = create(:practice_exercise, slug: "ex_prac_enums", track:)
    practice_exercise.prerequisites << enums
    practice_exercise.practiced_concepts << enums

    user = create :user
    user_track = create(:user_track, track:, user:)
    create :hello_world_solution, :completed, track:, user: user_track.user

    # The basics exercise has not been completed so no unlocked concepts
    assert_empty user_track.unlocked_concepts_for_exercise(basics_exercise)

    # Completing the basics exercise unlocks the enums concept
    create(:concept_solution, :completed, exercise: basics_exercise, user:)

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_equal [enums], user_track.unlocked_concepts_for_exercise(basics_exercise)

    # Completing the enums exercise unlocks the strings concepts
    create(:concept_solution, :completed, exercise: enums_exercise, user:)

    # Reload the user track to override memoizing
    user_track.reset_summary!

    assert_equal [enums, strings], user_track.unlocked_concepts_for_exercise(basics_exercise)
  end

  test "maintainer?" do
    track = create :track
    user = create :user, uid: '12389123'
    user_track = create(:user_track, track:, user:)

    refute user_track.maintainer?

    user.update(roles: [:maintainer])
    refute user_track.reload.maintainer?

    create :github_team_member, user_id: user.uid, team_name: track.github_team_name
    assert user_track.reload.maintainer?
  end

  test "course?" do
    track = create :track
    non_maintainer = create :user
    non_maintainer_user_track = create :user_track, track:, user: non_maintainer
    maintainer = create :user, :maintainer, uid: '256123'
    maintainer_user_track = create :user_track, track:, user: maintainer

    track.update(course: true)
    assert non_maintainer_user_track.course?
    assert maintainer_user_track.course?

    track.update(course: false)
    refute non_maintainer_user_track.course?
    refute maintainer_user_track.course?

    create(:concept_exercise, status: :wip, track:)
    refute non_maintainer_user_track.course?
    refute maintainer_user_track.course?

    # Only track maintainer that are in the track's GitHub team are excempted
    create :github_team_member, user_id: maintainer.uid, team_name: track.github_team_name
    refute non_maintainer_user_track.reload.course?
    assert maintainer_user_track.reload.course?
  end
end
