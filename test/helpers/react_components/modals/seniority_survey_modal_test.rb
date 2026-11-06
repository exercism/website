require_relative "../react_component_test_case"

class ReactComponents::Modals::SenioritySurveyModalTest < ReactComponentTestCase
  test "shows to a user who signed up before the sign-up page asked for seniority" do
    user = create :user, seniority: nil, created_at: cutoff - 1.day
    session = {}
    component = component_for(user, session:)

    assert_component component,
      "modals-seniority-survey-modal",
      {
        links: {
          hide_modal_endpoint: Exercism::Routes.hide_api_settings_introducer_path("seniority-survey-modal"),
          api_user_endpoint: Exercism::Routes.api_user_url,
          coding_fundamentals_course: Courses::CodingFundamentals.url
        }
      }
    assert session[ReactComponents::Modals::SenioritySurveyModal::SHOWN_AT_FLAG].present?
  end

  test "never shows to a user who signed up after the sign-up page asked for seniority" do
    user = create :user, seniority: nil, created_at: cutoff + 1.second
    session = {}
    component = component_for(user, session:)

    assert_nil component.to_s
    assert_nil session[ReactComponents::Modals::SenioritySurveyModal::SHOWN_AT_FLAG]
  end

  test "does not show to an older user who has a seniority" do
    user = create :user, seniority: :mid, created_at: cutoff - 1.day

    assert_nil component_for(user).to_s
  end

  test "does not show if another modal is showing" do
    user = create :user, seniority: nil, created_at: cutoff - 1.day

    assert_nil component_for(user, showing_modal: true).to_s
  end

  private
  def cutoff = User::DetermineIfOnboardingAsksSeniority::SIGN_UP_ASKS_SENIORITY_FROM

  def component_for(user, session: {}, showing_modal: false)
    ReactComponents::Modals::SenioritySurveyModal.new.tap do |component|
      component.stubs(current_user: user, session:)
      component.stubs(:showing_modal?).returns(showing_modal)
      component.stubs(:showing_modal!)
    end
  end
end
