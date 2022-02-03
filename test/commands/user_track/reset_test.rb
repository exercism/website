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
end
