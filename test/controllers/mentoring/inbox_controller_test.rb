require "test_helper"

class Mentoring::InboxControllerTest < ActionDispatch::IntegrationTest
  test "redirects non mentors" do
    user = create :user, :not_mentor
    sign_in!(user)

    get mentoring_inbox_path
    assert_redirected_to mentoring_path
  end
end
