require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "show: should 302 if not signed in" do
    get admin_root_path

    assert_response :redirect
  end

  test "show: should 302 if not staff" do
    sign_in!

    get admin_root_path

    assert_response :redirect
  end

  test "show: should 200 if staff" do
    sign_in!(create(:user, :staff))

    get admin_root_path

    assert_response :success
  end
end
