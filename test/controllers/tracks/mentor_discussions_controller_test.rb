require "test_helper"

class Tracks::MentorDiscussionsControllerTest < ActionDispatch::IntegrationTest
  test "index: no solution" do
    user = create :user
    exercise = create :practice_exercise

    sign_in!(user)
    get track_exercise_mentor_discussions_url(exercise.track, exercise)
    assert_redirected_to track_exercise_path(exercise.track, exercise)
  end

  test "index: no iterations" do
    user = create :user
    solution = create(:concept_solution, user:)

    sign_in!(user)
    get track_exercise_mentor_discussions_url(solution.track, solution.exercise)
    assert_redirected_to track_exercise_path(solution.track, solution.exercise)
  end

  test "index: first-time" do
    user = create :user
    solution = create(:concept_solution, user:)
    create :iteration, submission: create(:submission, solution:)

    sign_in!(user)
    get track_exercise_mentor_discussions_url(solution.track, solution.exercise)

    assert_response :ok
    assert_includes @response.body, "Take your solution to the next level"
    assert_includes @response.body, "You have no past code review sessions"
  end

  test "index: requested" do
    user = create :user
    solution = create(:concept_solution, user:)
    create :iteration, submission: create(:submission, solution:)
    create(:mentor_request, solution:)

    sign_in!(user)
    get track_exercise_mentor_discussions_url(solution.track, solution.exercise)

    assert_response :ok
    assert_includes @response.body, "You&apos;ve requested mentoring"
    assert_includes @response.body, "You have no past code review sessions"
  end

  test "index: in-progress" do
    user = create :user
    solution = create(:concept_solution, user:)
    create :iteration, submission: create(:submission, solution:)
    create(:mentor_discussion, solution:)

    sign_in!(user)
    get track_exercise_mentor_discussions_url(solution.track, solution.exercise)

    assert_response :ok
    assert_includes @response.body, "You're being mentored by"
    assert_includes @response.body, "You have no past code review sessions"
  end

  test "index: finished" do
    user = create :user
    solution = create(:concept_solution, user:)
    create :iteration, submission: create(:submission, solution:)
    create :mentor_discussion, solution:, finished_at: Time.current - 10.days, status: :finished

    sign_in!(user)
    get track_exercise_mentor_discussions_url(solution.track, solution.exercise)

    assert_response :ok
    assert_includes @response.body, "Want to try another mentor?"
    assert_includes @response.body, "Ended 10 days ago"
  end

  test "show: no solution" do
    user = create :user
    exercise = create :practice_exercise

    sign_in!(user)
    assert_raises ActiveRecord::RecordNotFound do
      get track_exercise_mentor_discussion_url(exercise.track, exercise, "foobar")
    end
  end
end
