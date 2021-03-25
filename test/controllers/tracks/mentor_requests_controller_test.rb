require "test_helper"

class Tracks::MentorRequestsControllerTest < ActionDispatch::IntegrationTest
  test "new: redirects to show when a mentor request is pending" do
    user = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, user: user, exercise: exercise
    create :solution_mentor_request, solution: solution

    sign_in!(user)
    get new_track_exercise_mentor_request_url(track, exercise)

    assert_redirected_to track_exercise_mentor_request_url(track, exercise)
  end

  test "redirects fullfiled requests" do
    user = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, user: user, exercise: exercise
    request = create :solution_mentor_request, solution: solution, status: :fulfilled
    discussion = create :solution_mentor_discussion, request: request

    sign_in!(user)

    get track_exercise_mentor_request_url(track, exercise)
    assert_redirected_to track_exercise_mentor_discussion_url(track, exercise, discussion)
  end
end
