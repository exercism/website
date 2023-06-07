class Payments::Paypal::Subscription::CreateForPremium
  include Mandate

  initialize_with :user, :interval

  def call
    response = RestClient.post(url, body.to_json, headers)
    JSON.parse(response.body, symbolize_names: true).tap do |paypal_subscription|
      create_subscription!(paypal_subscription)
    end
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  private
  def create_subscription!(paypal_subscription)
    Payments::Paypal::Subscription::Create.(user, paypal_subscription[:id], amount_in_dollars, :premium, interval, status: :pending)
  end

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
      custom_id: user.id,
      application_context: {
        return_url: Exercism::Routes.paypal_pending_premium_url,
        cancel_url: Exercism::Routes.paypal_cancelled_premium_url
      }
    }
  end

  def headers
    {
      authorization:,
      content_type: :json,
      accept: :json,
      prefer: 'return=minimal'
    }
  end

  def authorization = "Bearer #{access_token}"
  def access_token = Payments::Paypal::RequestAccessToken.()
  def product = :premium
  def amount_in_dollars = Premium.amount_in_dollars_from_interval(interval)
  def amount = amount_in_dollars.to_s
  def plan_id = Payments::Paypal.plan_id_from_interval(interval)
end
