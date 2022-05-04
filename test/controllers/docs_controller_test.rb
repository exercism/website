require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "docs shows when logged out" do
    get docs_path
    assert_response 200
  end

  test "docs shows when logged in" do
    sign_in!
    get docs_path
    assert_response 200
  end

  test "docs shows when not onboarded" do
    user = create :user, :not_onboarded
    sign_in!(user)
    get docs_path
    assert_response 200
  end
end
