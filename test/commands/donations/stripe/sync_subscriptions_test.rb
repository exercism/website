require_relative '../test_base'

class Donations::Stripe::SyncSubscriptionsTest < Donations::TestBase
  test "creates subscription for subscriptions only in Stripe" do
    user_1 = create :user, stripe_customer_id: "cus_1"
    user_2 = create :user, stripe_customer_id: "cus_2"

    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?limit=100&query=status:'active'").
      to_return(
        status: 200,
        body: {
          "object": "search_result",
          "url": "/v1/subscriptions/search",
          "has_more": false,
          "data": [
            {
              "id": "su_1",
              "object": "subscription",
              "customer": "cus_1",
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999
                    },
                    "subscription": "sub_1"
                  }
                ],
                "has_more": false,
                "url": "/v1/subscription_items?subscription=sub_1"
              },
              "status": "active"
            },
            {
              "id": "su_2",
              "object": "subscription",
              "customer": "cus_2",
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_2",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_2",
                      "object": "price",
                      "unit_amount": 777
                    },
                    "subscription": "sub_2"
                  }
                ],
                "has_more": false,
                "url": "/v1/subscription_items?subscription=sub_2"
              },
              "status": "active"
            }
          ]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    refute Donations::Subscription.exists?

    Donations::Stripe::SyncSubscriptions.()

    assert_equal 2, Donations::Subscription.count

    assert_equal 1, user_1.donation_subscriptions.count
    subscription_1 = user_1.donation_subscriptions.first
    assert subscription_1.active
    assert_equal "su_1", subscription_1.stripe_id
    assert_equal 999, subscription_1.amount_in_cents

    assert_equal 1, user_2.donation_subscriptions.count
    subscription_2 = user_2.donation_subscriptions.first
    assert subscription_2.active
    assert_equal "su_2", subscription_2.stripe_id
    assert_equal 777, subscription_2.amount_in_cents
  end

  test "gracefully handles subscriptions only in Stripe that can't be linked to a user" do
    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?limit=100&query=status:'active'").
      to_return(
        status: 200,
        body: {
          "object": "search_result",
          "url": "/v1/subscriptions/search",
          "has_more": false,
          "data": [
            {
              "id": "su_1",
              "object": "subscription",
              "customer": "cus_1",
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999
                    },
                    "subscription": "sub_1"
                  }
                ],
                "has_more": false,
                "url": "/v1/subscription_items?subscription=sub_1"
              },
              "status": "active"
            }
          ]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    refute Donations::Subscription.exists?

    Donations::Stripe::SyncSubscriptions.()

    refute Donations::Subscription.exists?
  end

  test "does not change subscriptions with matching Stripe status" do
    user_1 = create :user, stripe_customer_id: "cus_1"
    user_2 = create :user, stripe_customer_id: "cus_2"

    subscription_1 = create :donations_subscription, user: user_1, stripe_id: "su_1", amount_in_cents: 999,
      updated_at: Time.utc(2022, 3, 18)
    subscription_2 = create :donations_subscription, user: user_2, stripe_id: "su_2", amount_in_cents: 777,
      updated_at: Time.utc(2022, 4, 22)

    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?limit=100&query=status:'active'").
      to_return(
        status: 200,
        body: {
          "object": "search_result",
          "url": "/v1/subscriptions/search",
          "has_more": false,
          "data": [
            {
              "id": "su_1",
              "object": "subscription",
              "customer": "cus_1",
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999
                    },
                    "subscription": "sub_1"
                  }
                ],
                "has_more": false,
                "url": "/v1/subscription_items?subscription=sub_1"
              },
              "status": "active"
            },
            {
              "id": "su_2",
              "object": "subscription",
              "customer": "cus_2",
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_2",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_2",
                      "object": "price",
                      "unit_amount": 777
                    },
                    "subscription": "sub_2"
                  }
                ],
                "has_more": false,
                "url": "/v1/subscription_items?subscription=sub_2"
              },
              "status": "active"
            }
          ]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    assert_equal 2, Donations::Subscription.count

    Donations::Stripe::SyncSubscriptions.()

    assert_equal 2, Donations::Subscription.count
    assert subscription_1.reload.active?
    assert subscription_2.reload.active?
    assert_equal Time.utc(2022, 3, 18), subscription_1.updated_at
    assert_equal Time.utc(2022, 4, 22), subscription_2.updated_at
  end

  test "deactivates subscriptions that are not active in Stripe" do
    user_1 = create :user, stripe_customer_id: "cus_1"
    user_2 = create :user, stripe_customer_id: "cus_2"

    subscription_1 = create :donations_subscription, user: user_1, stripe_id: "su_1", amount_in_cents: 999,
      updated_at: Time.utc(2022, 3, 18)
    subscription_2 = create :donations_subscription, user: user_2, stripe_id: "su_2", amount_in_cents: 777,
      updated_at: Time.utc(2022, 4, 22)

    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?limit=100&query=status:'active'").
      to_return(
        status: 200,
        body: {
          "object": "search_result",
          "url": "/v1/subscriptions/search",
          "has_more": false,
          "data": [
            {
              "id": "su_1",
              "object": "subscription",
              "customer": "cus_1",
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999
                    },
                    "subscription": "sub_1"
                  }
                ],
                "has_more": false,
                "url": "/v1/subscription_items?subscription=sub_1"
              },
              "status": "active"
            }
          ]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    assert_equal 2, Donations::Subscription.count
    assert subscription_1.active?
    assert subscription_2.active?

    Donations::Stripe::SyncSubscriptions.()

    assert_equal 2, Donations::Subscription.count
    assert subscription_1.reload.active?
    refute subscription_2.reload.active?
  end
end
