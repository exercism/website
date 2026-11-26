require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "show: should 302 if not signed in" do
    get admin_root_path

    assert_response :redirect
  end

  test "show: should 302 if not a maintainer admin" do
    sign_in!

    get admin_root_path

    assert_response :redirect
  end

  test "show: should 200 if a maintainer admin" do
    sign_in!(create(:user, :maintainer_admin))

    get admin_root_path

    assert_response :success
  end
end
