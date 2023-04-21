require "test_helper"

class Tracks::MentorRequestsControllerTest < ActionDispatch::IntegrationTest
  test "new: redirects to show when a mentor request is pending" do
    user = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, user:, exercise:)
    create(:mentor_request, solution:)

    sign_in!(user)
    get new_track_exercise_mentor_request_url(track, exercise)

    assert_redirected_to track_exercise_mentor_request_url(track, exercise)
  end

  test "new: redirects to show when a mentor discussion is in progress" do
    user = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, user:, exercise:)
    create(:mentor_discussion, solution:)

    sign_in!(user)
    get new_track_exercise_mentor_request_url(track, exercise)

    assert_redirected_to track_exercise_mentor_request_url(track, exercise)
  end

  test "redirects fullfiled requests" do
    user = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, user:, exercise:)
    request = create :mentor_request, solution:, status: :fulfilled
    discussion = create(:mentor_discussion, request:)

    sign_in!(user)

    get track_exercise_mentor_request_url(track, exercise)
    assert_redirected_to track_exercise_mentor_discussion_url(track, exercise, discussion)
  end
end
