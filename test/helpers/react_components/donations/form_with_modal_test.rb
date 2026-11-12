require_relative "../react_component_test_case"

class ReactComponents::Donations::FormWithModalTest < ReactComponentTestCase
  test "renders the signed-in user's donation form data" do
    user = create :user

    component = ReactComponents::Donations::FormWithModal.new
    component.stubs(current_user: user)

    assert_component(
      component,
      "donations-with-modal-form",
      {
        request: {
          endpoint: Exercism::Routes.current_api_payments_subscriptions_url,
          options: {
            initial_data: AssembleCurrentSubscription.(user)
          }
        },
        captcha_required: user.captcha_required?,
        recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
        links: {
          settings: Exercism::Routes.donations_settings_url,
          success: Exercism::Routes.donated_url
        }
      }
    )
  end
end
