require "test_helper"

class Maintaining::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "show - redirects non maintainers" do
    user = create :user
    sign_in!(user)

    get maintaining_root_path
    assert_redirected_to root_path
  end

  test "show - shows for maintainer" do
    user = create :user, :maintainer
    sign_in!(user)

    get maintaining_root_path
    assert_response :ok
  end
end
