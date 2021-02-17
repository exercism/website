require "test_helper"

class Mentoring::ExternalControllerTest < ActionDispatch::IntegrationTest
  test "redirects mentors" do
    user = create :user
    sign_in!(user)

    get mentoring_path
    assert_redirected_to mentoring_dashboard_path
  end
end
