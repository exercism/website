require "test_helper"

class Solution::CompleteWithSummaryTest < ActiveSupport::TestCase
  test "sets solution as completed" do
    freeze_time do
      track = create :track
      concept_1 = create(:concept, track:)
      concept_2 = create(:concept, track:)

      concept_exercise_1 = create :concept_exercise, track:, slug: "lasagna"
      concept_exercise_1.taught_concepts << concept_1

      concept_exercise_2 = create :concept_exercise, track:, slug: "concept-exercise-2"
      concept_exercise_2.taught_concepts << concept_2
      concept_exercise_2.prerequisites << concept_1

      practice_exercise_1 = create :practice_exercise, track:, slug: "two-fer"
      practice_exercise_1.practiced_concepts << concept_1
      practice_exercise_1.prerequisites << concept_1

      practice_exercise_2 = create :practice_exercise, track:, slug: "bob"
      practice_exercise_2.prerequisites << concept_1

      practice_exercise_3 = create :practice_exercise, track:, slug: "leap"
      practice_exercise_3.prerequisites << concept_2

      user = create :user
      user_track = create(:user_track, user:, track:)
      solution = create :concept_solution, user:, exercise: concept_exercise_1
      submission = create(:submission, solution:)
      create(:iteration, submission:)

      summary = UserTrack::MonitorChanges.(user_track) do
        Solution::Complete.(solution, user_track)
      end

      assert_equal [concept_exercise_2, practice_exercise_1, practice_exercise_2], summary[:unlocked_exercises]
      assert_equal [concept_2], summary[:unlocked_concepts]

      expected = [{
        total: 2,
        from: 0,
        to: 1,
        concept: concept_1
      }]
      assert_equal expected, summary[:concept_progressions]
    end
  end
end
