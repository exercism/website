require "test_helper"

class Mentoring::QueueControllerTest < ActionDispatch::IntegrationTest
  test "redirects non mentors" do
    user = create :user, :not_mentor
    sign_in!(user)

    get mentoring_queue_path
    assert_redirected_to mentoring_path
  end
end
