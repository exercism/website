require "test_helper"

class Tracks::MentorRequestsControllerTest < ActionDispatch::IntegrationTest
  test "new: redirects to show when a mentor request is pending" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
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
    create(:user_track, user:, track:)
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, user:, exercise:)
    create(:mentor_discussion, solution:)

    sign_in!(user)
    get new_track_exercise_mentor_request_url(track, exercise)

    assert_redirected_to track_exercise_mentor_request_url(track, exercise)
  end

  test "new: redirects when no mentor slots remaining" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:concept_exercise, track:)
    create(:concept_solution, user:, exercise:)

    # Create other existing requests for this track
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))

    sign_in!(user)
    get new_track_exercise_mentor_request_url(track, exercise)

    assert_redirected_to get_more_slots_track_exercise_mentor_request_url(track, exercise)
  end

  test "new: redirects when max mentoring slots taken for insiders" do
    user = create :user, :insider
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:concept_exercise, track:)
    create(:concept_solution, user:, exercise:)

    # Create other existing requests for this track
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))

    sign_in!(user)
    get new_track_exercise_mentor_request_url(track, exercise)

    assert_redirected_to no_slots_remaining_track_exercise_mentor_request_url(track, exercise)
  end

  test "new: redirects when max mentoring slots taken for high rep user" do
    user = create :user, reputation: 9_999_999
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:concept_exercise, track:)
    create(:concept_solution, user:, exercise:)

    # Create other existing requests for this track
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))
    create(:mentor_request, solution: create(:concept_solution, user:, exercise: create(:concept_exercise, :random_slug, track:)))

    sign_in!(user)
    get new_track_exercise_mentor_request_url(track, exercise)

    assert_redirected_to no_slots_remaining_track_exercise_mentor_request_url(track, exercise)
  end

  test "redirects fullfiled requests" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, user:, exercise:)
    request = create :mentor_request, solution:, status: :fulfilled
    discussion = create(:mentor_discussion, request:)

    sign_in!(user)

    get track_exercise_mentor_request_url(track, exercise)
    assert_redirected_to track_exercise_mentor_discussion_url(track, exercise, discussion)
  end
end
