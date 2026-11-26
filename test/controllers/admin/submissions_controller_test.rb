require "test_helper"

class Admin::SubmissionsControllerTest < ActionDispatch::IntegrationTest
  test "index - redirects maintainers" do
    user = create :user, :maintainer
    sign_in!(user)

    get admin_submissions_path
    assert_response :redirect
  end

  test "index - redirects non maintainers" do
    user = create :user
    sign_in!(user)

    get admin_submissions_path
    assert_redirected_to root_path
  end

  test "index - shows for maintainer admin" do
    user = create :user, :maintainer_admin
    sign_in!(user)

    get admin_submissions_path
    assert_response :ok
  end
end
