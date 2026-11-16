require_relative '../../test_base'

class Payments::Stripe::BillingPortal::CreateSessionTest < Payments::TestBase
  test "returns the url of a new portal session" do
    user = create :user, stripe_customer_id: "cus_123"
    return_url = "https://exercism.org/settings/donations"

    Stripe::BillingPortal::Session.expects(:create).with(
      customer: "cus_123",
      return_url:
    ).returns(OpenStruct.new(url: "https://billing.stripe.com/session/abc"))

    assert_equal "https://billing.stripe.com/session/abc",
      Payments::Stripe::BillingPortal::CreateSession.(user, return_url)
  end

  test "returns nil without calling stripe if the user has no stripe customer" do
    user = create :user, stripe_customer_id: nil

    Stripe::BillingPortal::Session.expects(:create).never

    assert_nil Payments::Stripe::BillingPortal::CreateSession.(user, "https://exercism.org/settings/donations")
  end
end
