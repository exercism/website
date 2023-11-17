require "test_helper"

class UserTrack::ViewedExerciseApproachTest < ActiveSupport::TestCase
  test "materializes exercise from approach" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)

    viewed_approach = UserTrack::ViewedExerciseApproach.create!(user:, track:, approach:)
    assert_equal exercise, viewed_approach.exercise
  end
end
