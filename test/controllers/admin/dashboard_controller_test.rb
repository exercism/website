require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "show: should 302 if not signed in" do
    get admin_root_path

    assert_response :redirect
  end

  test "show: redirects users below maintainer" do
    sign_in!(create(:user, :staff))

    get admin_root_path

    assert_redirected_to root_path
  end

  test "show: maintainers see only the maintainer pages" do
    sign_in!(create(:user, :maintainer))

    get admin_root_path

    assert_response :success
    assert_select ".c-admin-dashboard-group h2", text: "Maintainer"
    assert_select ".c-admin-dashboard-group h2", text: "Maintainer admin", count: 0
    assert_select ".c-admin-dashboard-group h2", text: "Admin", count: 0
  end

  test "show: maintainer admins see two groups" do
    sign_in!(create(:user, :maintainer_admin))

    get admin_root_path

    assert_response :success
    assert_select ".c-admin-dashboard-group h2", count: 2
    assert_select ".c-admin-dashboard-group h2", text: "Admin", count: 0
  end

  test "show: admins see every group" do
    sign_in!(create(:user, :admin))

    get admin_root_path

    assert_response :success
    assert_select ".c-admin-dashboard-group h2", count: 3
  end
end
