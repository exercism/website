require_relative '../../test_base'

class Payments::Paypal::Subscription::CreateForPremiumTest < Payments::TestBase
  [
    [:month, '9.99', 'P-0TT41792VT226690TMR43JAQ'],
    [:year, '99.99', 'P-7TW18726BH9867209MR43JIA']
  ].each do |(interval, amount_in_dollars, plan_id)|
    test "correctly creates #{interval} premium subscription" do
      user = create :user
      access_token = SecureRandom.compact_uuid

      request_body = {
        plan_id:,
        subscriber: {
          name: {
            given_name: user.name
          },
          email_address: user.email
        },
        shipping_amount: {
          currency_code: "USD",
          value: amount_in_dollars
        },
        custom_id: user.id,
        application_context: {
          return_url: "https://test.exercism.org/premium/paypal_pending",
          cancel_url: "https://test.exercism.org/premium/paypal_cancelled"
        }
      }
      response_body = {
        status: "APPROVAL_PENDING",
        id: SecureRandom.compact_uuid,
        links: [
          {
            href: "https://www.sandbox.paypal.com/webapps/billing/subscriptions?ba_token=#{SecureRandom.compact_uuid}",
            rel: "approve",
            method: "GET"
          }
        ]
      }

      stub_request(:post, "https://api-m.sandbox.paypal.com/v1/billing/subscriptions").
        with(
          body: request_body.to_json,
          headers: {
            Accept: 'application/json',
            Authorization: "Bearer #{access_token}",
            'Content-Type': 'application/json',
            Prefer: 'return=minimal'
          }
        ).
        to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type': 'application/json' })

      Payments::Paypal::RequestAccessToken.expects(:call).returns(access_token)

      subscription = Payments::Paypal::Subscription::CreateForPremium.(user, interval)
      assert_equal response_body, subscription
    end
  end
end
