require "test_helper"

class Solution::CompleteWithSummaryTest < ActiveSupport::TestCase
  test "sets solution as completed" do
    freeze_time do
      track = create :track
      concept_1 = create :track_concept, track: track
      concept_2 = create :track_concept, track: track

      concept_exercise_1 = create :concept_exercise, track: track, slug: "foo"
      concept_exercise_1.taught_concepts << concept_1
      practice_exercise = create :practice_exercise, track: track, slug: "prac"
      practice_exercise.prerequisites << concept_1

      concept_exercise_2 = create :concept_exercise, track: track, slug: "bar"
      concept_exercise_2.prerequisites << concept_1
      concept_exercise_2.taught_concepts << concept_2

      user = create :user
      user_track = create :user_track, user: user, track: track
      solution = create :concept_solution, user: user, exercise: concept_exercise_1

      summary = UserTrack::MonitorChanges.(user_track) do
        Solution::Complete.(solution, user_track)
      end

      assert_equal [practice_exercise, concept_exercise_2], summary[:unlocked_exercises]
      assert_equal [concept_2], summary[:unlocked_concepts]

      expected = [{
        concept: concept_1,
        from: 0,
        to: 1,
        total: 2
      }]
      assert_equal expected, summary[:concept_progressions]
    end
  end
end
