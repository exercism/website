require "test_helper"

class UserOnboardingControllerTest < ActionDispatch::IntegrationTest
  test "shows non onboarded user the page" do
    user = create :user, :not_onboarded

    sign_in!(user)
    get user_onboarding_path
    assert_response :ok
    assert_select "#page-onboarding"
  end

  test "redirects onboarded user" do
    sign_in!
    get user_onboarding_path
    assert_redirected_to dashboard_path
  end

  test "asks the sign-up questions first when the user has no seniority" do
    user = create :user, :not_onboarded, seniority: nil

    sign_in!(user)
    get user_onboarding_path
    assert_response :ok
    assert_select "#page-sign-up [data-step='level']"
    assert_select "form[data-sign-up-answers-form]"
    assert_select "#page-onboarding", count: 0
  end

  test "records the sign-up answers and moves on to the terms" do
    user = create :user, :not_onboarded, seniority: nil
    track = create :track, slug: "go"

    sign_in!(user)
    patch user_onboarding_path, params: { seniority: "junior", sign_up_track_slug: "go" }
    assert_redirected_to user_onboarding_path

    assert_equal :junior, user.data.reload.seniority
    assert_equal track, user.data.sign_up_track

    get user_onboarding_path
    assert_select "#page-onboarding"
  end

  test "does not change the answers of a user who already has a seniority" do
    user = create :user, :not_onboarded, seniority: :senior

    sign_in!(user)
    patch user_onboarding_path, params: { seniority: "beginner" }
    assert_redirected_to user_onboarding_path

    assert_equal :senior, user.data.reload.seniority
  end
end
