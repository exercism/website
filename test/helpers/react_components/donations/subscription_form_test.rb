require_relative "../react_component_test_case"

class ReactComponents::Donations::SubscriptionFormTest < ReactComponentTestCase
  test "includes the card update link for a stripe subscription" do
    user = create :user
    subscription = create(:payments_subscription, user:, status: :active, provider: :stripe)

    component = ReactComponents::Donations::SubscriptionForm.new
    component.stubs(current_user: user)

    assert_component(
      component,
      "donations-subscription-form",
      {
        links: {
          cancel: Exercism::Routes.cancel_api_payments_subscription_url(subscription),
          update: Exercism::Routes.update_amount_api_payments_subscription_url(subscription),
          update_card: Exercism::Routes.settings_stripe_billing_portal_url
        },
        provider: "stripe",
        amount_in_cents: subscription.amount_in_cents
      }
    )
  end
end
