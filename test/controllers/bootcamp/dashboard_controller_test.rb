require "test_helper"

class Bootcamp::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "image_proxy returns bad_request for invalid URI characters" do
    user = create(:user, :with_bootcamp_data, bootcamp_attendee: true)
    sign_in!(user)

    get bootcamp_image_proxy_path(filename: "check-circle", format: "svg>")
    assert_response :bad_request
  end
end
