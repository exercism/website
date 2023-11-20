require "test_helper"

class UserTrack::ViewedCommunitySolutionTest < ActiveSupport::TestCase
  test "materializes exercise from solution" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:)
    solution = create(:practice_solution, exercise:, user:)

    viewed_solution = UserTrack::ViewedCommunitySolution.create!(user:, track:, solution:)
    assert_equal exercise, viewed_solution.exercise
  end
end
