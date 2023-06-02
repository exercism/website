class Payments::Paypal::Subscription::CreateForPremium
  include Mandate

  initialize_with :user, :interval

  def call
    response = RestClient.post(url, body.to_json, headers)
    JSON.parse(response.body, symbolize_names: true)
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
      custom_id: user.email,
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
  def amount = Payments::Paypal.amount_in_dollars_from_interval(interval).to_s
  def plan_id = Payments::Paypal.plan_id_from_interval(interval)
end
