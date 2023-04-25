require "test_helper"

class Admin::AdminControllerTest < ActionDispatch::IntegrationTest
  test "index: should 302 if not signed in" do
    get admin_root_path

    assert_response :redirect
  end

  test "index: should 302 if not staff" do
    sign_in!

    get admin_root_path

    assert_response :redirect
  end

  test "index: should 200 if staff" do
    sign_in!(create(:user, :staff))

    get admin_root_path

    assert_response :success
  end
end
