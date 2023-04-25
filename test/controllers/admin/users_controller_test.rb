require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  %w[admin_users_path search_admin_users_path].each do |route|
    test "get #{route}: should 302 if not signed in" do
      get send(route)

      assert_response :redirect
    end

    test "get #{route}: should 302 if not staff" do
      sign_in!

      get send(route)

      assert_response :redirect
    end

    test "get #{route}: should 200 if staff" do
      sign_in!(create(:user, :staff))

      get send(route)

      assert_response :success
    end
  end
end
