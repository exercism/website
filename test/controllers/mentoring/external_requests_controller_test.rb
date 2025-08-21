require "test_helper"

class Mentoring::ExternalRequestsControllerTest < ActionDispatch::IntegrationTest
  test "show: shows logged out page when logged out" do
    solution = create :practice_solution

    get solution.external_mentoring_request_url
    assert_template "mentoring/external_requests/show_logged_out"
  end

  test "show: shows not mentor page when user is not a mentor" do
    user = create :user, :not_mentor
    solution = create :practice_solution
    sign_in!(user)

    get solution.external_mentoring_request_url
    assert_template "mentoring/external_requests/show_not_mentor"
  end

  test "show: shows request page when user is a mentor" do
    user = create :user
    solution = create :practice_solution
    sign_in!(user)

    get solution.external_mentoring_request_url
    assert_template "mentoring/external_requests/show"
  end

  test "show: redirects to solution page if user submitted solution" do
    solution = create :practice_solution
    sign_in!(solution.user)

    get solution.external_mentoring_request_url
    assert_redirected_to Exercism::Routes.private_solution_path(solution)
  end

  test "accept: redirects to existing discussion page if solution has existing discussion not yet finished by student" do
    mentor = create :user
    solution = create :practice_solution
    discussion = create(:mentor_discussion, :awaiting_student, solution:, mentor:)
    sign_in!(mentor)

    patch accept_mentoring_external_request_url(solution.public_uuid)

    assert_equal 1, solution.mentor_discussions.count
    assert_redirected_to mentoring_discussion_path(discussion)
  end

  test "accept: redirects to new discussion page if existing discussion was finished by student" do
    mentor = create :user
    solution = create :practice_solution
    create(:mentor_discussion, :student_finished, solution:, mentor:)
    sign_in!(mentor)

    patch accept_mentoring_external_request_url(solution.public_uuid)

    assert_equal 2, solution.mentor_discussions.count
    assert_redirected_to mentoring_discussion_path(solution.mentor_discussions.last)
  end

  test "accept: redirects to new discussion page if there was no existing discussion" do
    mentor = create :user
    solution = create :practice_solution
    sign_in!(mentor)

    patch accept_mentoring_external_request_url(solution.public_uuid)

    assert_equal 1, solution.mentor_discussions.count
    assert_redirected_to mentoring_discussion_path(solution.mentor_discussions.last)
  end
end
