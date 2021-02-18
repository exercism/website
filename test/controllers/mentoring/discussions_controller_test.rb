require "test_helper"

class Mentoring::DiscussionsControllerTest < ActionDispatch::IntegrationTest
  test "redirects non mentors" do
    user = create :user, :not_mentor
    sign_in!(user)

    get mentoring_discussion_path(1)
    assert_redirected_to mentoring_path
  end
end
