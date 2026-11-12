require_relative "../react_component_test_case"

class ReactComponents::Modals::WelcomeModalTest < ReactComponentTestCase
  test "renders the welcome modal" do
    user = create :user

    assert_component component_for(user), "modals-welcome-modal", {
      num_tracks: ::Track.num_active,
      links: {
        hide_modal_endpoint: Exercism::Routes.hide_api_settings_introducer_path("welcome-modal")
      }
    }
  end

  private
  def component_for(user)
    ReactComponents::Modals::WelcomeModal.new.tap do |component|
      component.stubs(current_user: user)
      component.stubs(:showing_modal?).returns(false)
      component.stubs(:showing_modal!)
    end
  end
end
