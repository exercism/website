require "test_helper"

class Admin::DonorsControllerTest < ActionDispatch::IntegrationTest
  %w[admin_donors_url new_admin_donor_url].each do |route|
    test "get #{route} should 302 if not signed in" do
      get send(route)

      assert_response :redirect
    end

    test "get #{route} should 302 if not staff" do
      sign_in!

      get send(route)

      assert_response :redirect
    end

    test "get #{route} should 200 if staff" do
      sign_in!(create(:user, :staff))

      get send(route)

      assert_response :success
    end
  end
end
