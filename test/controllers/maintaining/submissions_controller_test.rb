require "test_helper"

class Maintaining::SubmissionsControllerTest < ActionDispatch::IntegrationTest
  test "index - redirects non maintainers" do
    user = create :user
    sign_in!(user)

    get maintaining_submissions_path
    assert_redirected_to root_path
  end

  test "index - shows for maintainer" do
    user = create :user, :maintainer
    sign_in!(user)

    get maintaining_submissions_path
    assert_response :ok
  end
end
