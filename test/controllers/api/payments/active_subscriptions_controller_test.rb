require_relative '../base_test_case'

class API::Payments::ActiveSubscriptionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_payments_active_subscription_path

  ########
  # Show #
  ########
  test "get last active subscription of specified product" do
    user = create :user
    create(:payments_subscription, :active, :premium, user:, amount_in_cents: 100)
    subscription = create(:payments_subscription, :active, :premium, :github, user:, amount_in_cents: 200)
    create(:payments_subscription, :canceled, :premium, user:, amount_in_cents: 300)
    create(:payments_subscription, :overdue, :premium, user:, amount_in_cents: 400)
    create(:payments_subscription, :active, :donation, user:, amount_in_cents: 400)

    setup_user(user)
    get api_payments_active_subscription_path(product: :premium), headers: @headers, as: :json

    assert_response :ok

    expected = {
      subscription: {
        provider: subscription.provider,
        interval: subscription.interval,
        amount_in_cents: subscription.amount_in_cents
      }
    }
    assert_equal(expected.to_json, response.body)
  end

  test "get without product defaults to last active donation subscription" do
    user = create :user
    create(:payments_subscription, :active, :donation, user:, amount_in_cents: 100)
    subscription = create(:payments_subscription, :active, :donation, :github, user:, amount_in_cents: 200)
    create(:payments_subscription, :canceled, :donation, user:, amount_in_cents: 300)
    create(:payments_subscription, :overdue, :donation, user:, amount_in_cents: 400)
    create(:payments_subscription, :active, :premium, user:, amount_in_cents: 400)

    setup_user(user)
    get api_payments_active_subscription_path, headers: @headers, as: :json

    assert_response :ok

    expected = {
      subscription: {
        provider: subscription.provider,
        interval: subscription.interval,
        amount_in_cents: subscription.amount_in_cents
      }
    }
    assert_equal(expected.to_json, response.body)
  end
end
