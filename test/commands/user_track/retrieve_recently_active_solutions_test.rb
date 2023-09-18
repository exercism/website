require 'test_helper'

class UserTrack::RetrieveRecentlyActiveSolutionsTest < ActiveSupport::TestCase
  test "orders correctly" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:)

    solution_1 = create :concept_solution
    solution_2 = create :concept_solution
    solution_3 = create :concept_solution
    create :started_exercise_user_activity, user:, track:, solution: solution_2
    create :started_exercise_user_activity, user:, track:, solution: solution_1
    create :started_exercise_user_activity, user:, track:, solution: solution_3

    solutions = UserTrack::RetrieveRecentlyActiveSolutions.(user_track)
    assert_equal [solution_3, solution_1, solution_2], solutions
  end

  test "filters by user and track" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:)

    solution = create :concept_solution
    create(:started_exercise_user_activity, user:, track:, solution:)
    create :started_exercise_user_activity, user:, track: create(:track, :random_slug),
      solution: create(:concept_solution)
    create :started_exercise_user_activity, track:, solution: create(:concept_solution)

    activities = UserTrack::RetrieveRecentlyActiveSolutions.(user_track)
    assert_equal [solution], activities
  end

  test "groups by solution_id and returns most recent" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:)
    solution_1 = create :concept_solution
    solution_2 = create :concept_solution

    create :started_exercise_user_activity, user:, track:, solution: solution_1
    create :started_exercise_user_activity, user:, track: create(:track, :random_slug), solution: solution_2
    create :submitted_iteration_user_activity, user:, track:, solution: solution_2

    activities = UserTrack::RetrieveRecentlyActiveSolutions.(user_track)
    assert_equal [solution_2, solution_1], activities
  end
end
