require "test_helper"

class LegacyControllerTest < ActionDispatch::IntegrationTest
  test "shows non onboarded user the page" do
    user = create :user, :not_onboarded

    sign_in!(user)
    get user_onboarding_path
    assert_response :ok
  end

  test "redirects onboarded user" do
    sign_in!
    get user_onboarding_path
    assert_redirected_to dashboard_path
  end
end
