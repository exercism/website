require "test_helper"

class Settings::StripeBillingPortalControllerTest < ActionDispatch::IntegrationTest
  test "redirects to the stripe portal session" do
    user = create :user, stripe_customer_id: "cus_123"
    sign_in!(user)

    Payments::Stripe::BillingPortal::CreateSession.expects(:call).
      with(user, donations_settings_url).
      returns("https://billing.stripe.com/session/abc")

    get settings_stripe_billing_portal_path

    assert_redirected_to "https://billing.stripe.com/session/abc"
  end

  test "redirects to donation settings if the user has no stripe customer" do
    sign_in!(create(:user, stripe_customer_id: nil))

    get settings_stripe_billing_portal_path

    assert_redirected_to donations_settings_path
  end

  test "requires sign in" do
    get settings_stripe_billing_portal_path

    assert_response :redirect
    refute_match "stripe.com", response.location
  end
end
