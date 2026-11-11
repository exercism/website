require_relative "../react_component_test_case"

class ReactComponents::Modals::WelcomeModalTest < ReactComponentTestCase
  test "asks for seniority for a user who signed up before the sign-up page did" do
    user = create :user, seniority: nil, created_at: cutoff - 1.day

    assert_component component_for(user), "modals-welcome-modal", expected_data(ask_seniority: true)
  end

  test "does not ask for seniority for a user who signed up after the sign-up page did" do
    user = create :user, seniority: nil, created_at: cutoff + 1.second

    assert_component component_for(user), "modals-welcome-modal", expected_data(ask_seniority: false)
  end

  private
  def cutoff = User::DetermineIfOnboardingAsksSeniority::SIGN_UP_ASKS_SENIORITY_FROM

  def component_for(user)
    ReactComponents::Modals::WelcomeModal.new.tap do |component|
      component.stubs(current_user: user)
      component.stubs(:showing_modal?).returns(false)
      component.stubs(:showing_modal!)
    end
  end

  def expected_data(ask_seniority:)
    {
      num_tracks: ::Track.num_active,
      ask_seniority:,
      links: {
        hide_modal_endpoint: Exercism::Routes.hide_api_settings_introducer_path("welcome-modal"),
        api_user_endpoint: Exercism::Routes.api_user_url,
        jiki: "https://jiki.io?utm_source=exercism&utm_medium=welcome_modal"
      }
    }
  end
end
