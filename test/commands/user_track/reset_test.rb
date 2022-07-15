require "test_helper"

class UserTrack::ResetTest < ActiveSupport::TestCase
  test "resets everything" do
    freeze_time do
      ghost_user = create :user, :ghost

      user = create :user
      track = create :track
      concept_exercise = create :concept_exercise
      practice_exercise = create :practice_exercise
      solution_1 = create :concept_solution, exercise: concept_exercise, user: user
      solution_2 = create :practice_solution, exercise: practice_exercise, user: user

      # Sanity checks
      assert_equal "#{user.id}:#{concept_exercise.id}", solution_1.unique_key
      assert_equal "#{user.id}:#{practice_exercise.id}", solution_2.unique_key

      user_track = create :user_track, user: user, track: track,
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

  test "removes track-specification reputation" do
    freeze_time do
      create :user, :ghost

      user = create :user
      track = create :track
      concept_exercise = create :concept_exercise, track: track
      practice_exercise = create :practice_exercise, track: track
      user_track = create :user_track, user: user, track: track
      solution_1 = create :concept_solution, exercise: concept_exercise, user: user
      solution_2 = create :practice_solution, exercise: practice_exercise, user: user
      create :iteration, solution: solution_1
      create :iteration, solution: solution_2

      # Sanity check: the user also has reputation in a different track,
      # which should not be lost
      other_track = create :track, :random_slug
      other_exercise = create :practice_exercise, track: other_track
      other_user_track = create :user_track, user: user, track: other_track
      other_solution = create :concept_solution, exercise: other_exercise, user: user
      create :iteration, solution: other_solution

      perform_enqueued_jobs do
        Solution::Publish.(solution_1, user_track, nil, 'MX')
        Solution::Publish.(solution_2, user_track, nil, 'MX')
        Solution::Publish.(other_solution, other_user_track, nil, 'MX')
      end

      # Sanity check
      assert_equal 3, user.reload.reputation

      UserTrack::Reset.(user_track)

      assert_equal 1, user.reload.reputation
    end
  end
end
