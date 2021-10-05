require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "works logged out" do
    get docs_path
    assert_response 200
  end

  test "works logged in" do
    sign_in!
    get docs_path
    assert_response 200
  end

  test "works not onboarded" do
    user = create :user, :not_onboarded
    sign_in!(user)
    get user_onboarding_path
    assert_response 200
  end
end
