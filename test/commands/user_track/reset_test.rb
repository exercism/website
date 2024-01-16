require "test_helper"

class UserTrack::ResetTest < ActiveSupport::TestCase
  test "resets everything" do
    freeze_time do
      ghost_user = create :user, :ghost

      user = create :user
      track = create :track
      concept_exercise = create :concept_exercise
      practice_exercise = create :practice_exercise
      solution_1 = create(:concept_solution, exercise: concept_exercise, user:)
      solution_2 = create(:practice_solution, exercise: practice_exercise, user:)

      # Sanity checks
      assert_equal "#{user.id}:#{concept_exercise.id}", solution_1.unique_key
      assert_equal "#{user.id}:#{practice_exercise.id}", solution_2.unique_key

      user_track = create :user_track, user:, track:,
        objectives: "something",
        anonymous_during_mentoring: true,
        created_at: Time.current - 1.week,
        updated_at: Time.current - 1.week,
        last_touched_at: Time.current - 1.week

      user_track.expects(:reset_summary!)

      UserTrack::Reset.(user_track)

      assert_equal ghost_user, solution_1.reload.user
      assert_equal ghost_user, solution_2.reload.user

      refute_equal "#{user.id}:#{concept_exercise.id}", solution_1.unique_key
      refute_equal "#{user.id}:#{practice_exercise.id}", solution_2.unique_key

      assert_nil user_track.objectives
      refute user_track.anonymous_during_mentoring
      assert_equal Time.current, user_track.updated_at
      assert_equal Time.current, user_track.last_touched_at
    end
  end

  test "remove solutions from search index" do
    create :user, :ghost
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:)

    Solution::RemoveUserSolutionsForTrackFromSearchIndex.expects(:defer).with(user.id, track.id)

    UserTrack::Reset.(user_track)
  end

  test "remove viewed community solutions" do
    create :user, :ghost
    user = create :user
    other_user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    user_track = create(:user_track, user:, track:)
    user_track_for_other_track = create(:user_track, user:, track: other_track)
    user_track_for_other_user = create(:user_track, user: other_user, track:)
    create(:user_track_viewed_community_solution, user:, track:)
    create(:user_track_viewed_community_solution, user:, track: other_track)
    create(:user_track_viewed_community_solution, user: other_user.user, track:)

    assert user_track.viewed_community_solutions.exists?
    assert user_track_for_other_track.viewed_community_solutions.exists?
    assert user_track_for_other_user.viewed_community_solutions.exists?

    UserTrack::Reset.(user_track)

    refute user_track.viewed_community_solutions.exists?
    assert user_track_for_other_track.viewed_community_solutions.exists?
    assert user_track_for_other_user.viewed_community_solutions.exists?
  end

  test "remove viewed exercise approaches" do
    create :user, :ghost
    user = create :user
    other_user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    user_track = create(:user_track, user:, track:)
    user_track_for_other_track = create(:user_track, user:, track: other_track)
    user_track_for_other_user = create(:user_track, user: other_user, track:)
    create(:user_track_viewed_exercise_approach, user:, track:)
    create(:user_track_viewed_exercise_approach, user:, track: other_track)
    create(:user_track_viewed_exercise_approach, user: other_user.user, track:)

    assert user_track.viewed_exercise_approaches.exists?
    assert user_track_for_other_track.viewed_exercise_approaches.exists?
    assert user_track_for_other_user.viewed_exercise_approaches.exists?

    UserTrack::Reset.(user_track)

    refute user_track.viewed_exercise_approaches.exists?
    assert user_track_for_other_track.viewed_exercise_approaches.exists?
    assert user_track_for_other_user.viewed_exercise_approaches.exists?
  end

  test "removes track-specification reputation" do
    Solution::PublishIteration.stubs(:call)

    freeze_time do
      create :user, :ghost

      user = create :user
      track = create :track
      concept_exercise = create(:concept_exercise, track:)
      practice_exercise = create(:practice_exercise, track:)
      user_track = create(:user_track, user:, track:)
      solution_1 = create(:concept_solution, exercise: concept_exercise, user:)
      solution_2 = create(:practice_solution, exercise: practice_exercise, user:)
      create :iteration, solution: solution_1
      create :iteration, solution: solution_2

      # Sanity check: the user also has reputation in a different track,
      # which should not be lost
      other_track = create :track, :random_slug
      other_exercise = create :practice_exercise, track: other_track
      other_user_track = create :user_track, user:, track: other_track
      other_solution = create(:concept_solution, exercise: other_exercise, user:)
      create :iteration, solution: other_solution

      perform_enqueued_jobs do
        Solution::Publish.(solution_1, user_track, nil)
        Solution::Publish.(solution_2, user_track, nil)
        Solution::Publish.(other_solution, other_user_track, nil)
      end

      # Sanity check
      assert_equal 3, user.reload.reputation

      UserTrack::Reset.(user_track)

      assert_equal 1, user.reload.reputation
    end
  end

  test "updates published solutions for exercise representations" do
    create :user, :ghost

    user = create :user
    other_user = create :user
    track = create :track
    concept_exercise = create(:concept_exercise, track:)
    practice_exercise = create(:practice_exercise, track:)
    user_track = create(:user_track, user:, track:)
    solution_1 = create(:concept_solution, :published, exercise: concept_exercise, user:)
    solution_2 = create(:practice_solution, :published, exercise: practice_exercise, user:)
    solution_3 = create(:practice_solution, :published, exercise: practice_exercise, user: other_user)
    representation_1 = create(:exercise_representation, exercise: concept_exercise)
    representation_2 = create(:exercise_representation, exercise: practice_exercise)
    solution_1.update(published_exercise_representation: representation_1)
    solution_2.update(published_exercise_representation: representation_2)
    solution_3.update(published_exercise_representation: representation_1)

    # Sanity check
    Exercise::Representation::Recache.(representation_1)
    Exercise::Representation::Recache.(representation_2)
    assert_equal 2, representation_1.num_published_solutions
    assert_equal 1, representation_2.num_published_solutions

    perform_enqueued_jobs do
      UserTrack::Reset.(user_track)
    end

    assert_nil solution_1.reload.published_exercise_representation
    assert_nil solution_2.reload.published_exercise_representation
    assert_equal 1, representation_1.reload.num_published_solutions
    assert_equal 0, representation_2.reload.num_published_solutions
  end

  test "remove pending and cancelled mentoring requests" do
    create :user, :ghost
    user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    user_track = create(:user_track, user:, track:)
    create(:user_track, user:, track: other_track)
    fulfilled_request = create :mentor_request, :fulfilled, student: user, exercise: create(:practice_exercise, track:)
    pending_request = create :mentor_request, :pending, student: user, exercise: create(:practice_exercise, track:)
    cancelled_request = create :mentor_request, :cancelled, student: user, exercise: create(:practice_exercise, track:)
    pending_request_other_track = create :mentor_request, :pending, student: user,
      exercise: create(:practice_exercise, track: other_track)
    cancelled_request_other_track = create :mentor_request, :cancelled, student: user,
      exercise: create(:practice_exercise, track: other_track)

    UserTrack::Reset.(user_track)

    assert_raises ActiveRecord::RecordNotFound, &proc { pending_request.reload }
    assert_raises ActiveRecord::RecordNotFound, &proc { cancelled_request.reload }
    assert_nothing_raised { fulfilled_request.reload }
    assert_nothing_raised { pending_request_other_track.reload }
    assert_nothing_raised { cancelled_request_other_track.reload }
  end
end
