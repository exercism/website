require "test_helper"

class Mentoring::RequestsControllerTest < ActionDispatch::IntegrationTest
  test "redirects non mentors" do
    user = create :user, :not_mentor
    sign_in!(user)

    get mentoring_request_path(1)
    assert_redirected_to mentoring_path
  end

  test "redirects locked" do
    mentor = create :user
    sign_in!(mentor)

    request = create :mentor_request, locked_by: create(:user), locked_until: Time.current + 5.minutes

    get mentoring_request_path(request)
    assert_redirected_to unavailable_mentoring_request_path(request)
  end

  test "redirects cancelled requests" do
    mentor = create :user
    sign_in!(mentor)

    request = create :mentor_request, status: :cancelled

    get mentoring_request_path(request)
    assert_redirected_to unavailable_mentoring_request_path(request)
  end

  test "redirects fulfilled requests with missing discussion" do
    mentor = create :user
    sign_in!(mentor)

    request = create :mentor_request, status: :fulfilled

    get mentoring_request_path(request)
    assert_redirected_to unavailable_mentoring_request_path(request)
  end

  test "redirects fulfilled requests by same mentor" do
    mentor = create :user
    sign_in!(mentor)

    request = create :mentor_request, status: :fulfilled
    discussion = create :mentor_discussion, request: request, mentor: mentor

    get mentoring_request_path(request)
    assert_redirected_to mentoring_discussion_path(discussion)
  end

  test "redirects fulfilled requests by different mentor" do
    mentor = create :user
    sign_in!(mentor)

    request = create :mentor_request, status: :fulfilled
    create :mentor_discussion, request: request

    get mentoring_request_path(request)
    assert_redirected_to unavailable_mentoring_request_path(request)
  end
end
