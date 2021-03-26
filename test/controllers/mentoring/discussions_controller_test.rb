require "test_helper"

class Mentoring::DiscussionsControllerTest < ActionDispatch::IntegrationTest
  test "redirects non mentors" do
    user = create :user, :not_mentor
    sign_in!(user)

    get mentoring_discussion_path(1)
    assert_redirected_to mentoring_path
  end

  test "redirects different mentor" do
    mentor = create :user
    sign_in!(mentor)

    discussion = create :mentor_discussion
    get mentoring_discussion_path(discussion)
    assert_redirected_to mentoring_path
  end

  test "shows for correct mentor" do
    mentor = create :user
    sign_in!(mentor)

    discussion = create :mentor_discussion, mentor: mentor
    get mentoring_discussion_path(discussion)
    assert_response :success
  end
end
