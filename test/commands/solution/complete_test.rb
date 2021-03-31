require "test_helper"

class Solution::CompleteTest < ActiveSupport::TestCase
  test "sets concept exercise solution as completed" do
    exercise = create :concept_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :concept_solution, user: user, exercise: exercise

    Solution::Complete.(solution, user_track)

    assert solution.reload.completed?
  end

  test "sets concept exercise concepts as learnt" do
    track = create :track
    concept = create :track_concept, track: track
    exercise = create :concept_exercise, track: track
    exercise.taught_concepts << concept

    user = create :user
    user_track = create :user_track, user: user, track: track
    solution = create :concept_solution, user: user, exercise: exercise

    Solution::Complete.(solution, user_track)

    assert user_track.concept_learnt?(concept)
  end

  test "sets practice exercise solution as completed" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise

    Solution::Complete.(solution, user_track)

    assert solution.reload.completed?
  end
end
