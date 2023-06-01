class Payments::Paypal::Subscription::CreateForPremium
  include Mandate

  initialize_with :user, :interval

  def call
    RestClient.post(url, body, headers)
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  private
  def url = "#{Exercism.config.paypal_api_url}/v1/billing/subscriptions"

  def body
    {
      plan_id:,
      subscriber: {
        name: {
          given_name: user.name
        },
        email_address: user.email
      },
      shipping_amount: {
        currency_code: "USD",
        value: amount
      },
      application_context: {
        user_action: "Join Exercism Premium",

        # TODO: set the URL to which the user is redirect when the payment was successful
        return_url: "https://example.com/returnUrl",

        # TODO: set the URL to which the user is redirect when the payment was cancelled
        cancel_url: "https://example.com/cancelUrl"
      }
    }
  end

  def headers
    {
      authorization:,
      content_type: :json,
      accept: :json
    }
  end

  def authorization = "Bearer #{access_token}"
  def access_token = Payments::Paypal::RequestAccessToken.()
  def product = :premium
  def amount = Premium.amount_in_dollars_from_interval(interval).to_s
end
