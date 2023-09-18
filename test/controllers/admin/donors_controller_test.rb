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

  test "create registers user as donor" do
    email = "jane@test.org"
    first_donated_at = Time.utc(2022, 4, 14)
    user = create(:user, :staff, email:)

    sign_in!(user)

    post admin_donors_url, params: { email:, first_donated_at: first_donated_at.to_s }

    assert user.reload.donated?
    assert_equal first_donated_at, user.first_donated_at
    assert_redirected_to admin_donors_url
  end

  test "create ignore leading and trailing whitespace in email" do
    email = "jane@test.org"
    first_donated_at = Time.utc(2022, 4, 14)
    user = create(:user, :staff, email:)

    sign_in!(user)

    post admin_donors_url, params: { email: "  jane@test.org   ", first_donated_at: first_donated_at.to_s }

    assert user.reload.donated?
    assert_equal first_donated_at, user.first_donated_at
    assert_redirected_to admin_donors_url
  end
end
