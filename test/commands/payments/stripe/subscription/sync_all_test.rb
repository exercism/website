require_relative '../../test_base'

class Payments::Stripe::Subscription::SyncAllTest < Payments::TestBase
  test "creates subscription for subscriptions only in Stripe with known stripe customer" do
    user_1 = create :user, stripe_customer_id: "cus_1"
    user_2 = create :user, stripe_customer_id: "cus_2"

    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?expand%5B%5D=data.customer&limit=100&query=status:'active'").
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
              "customer": {
                "id": "cus_1",
                "email": "user1@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999,
                      "product": Exercism.secrets.stripe_recurring_product_id,
                      "recurring": {
                        "interval": "month"
                      }
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
              "customer": {
                "id": "cus_2",
                "email": "user2@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_2",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_2",
                      "object": "price",
                      "unit_amount": 777,
                      "product": Exercism.secrets.stripe_premium_product_id,
                      "recurring": {
                        "interval": "year"
                      }
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

    refute Payments::Subscription.exists?

    Payments::Stripe::Subscription::SyncAll.()

    assert_equal 2, Payments::Subscription.count

    assert_equal 1, user_1.subscriptions.count
    subscription_1 = user_1.subscriptions.first
    assert_equal :active, subscription_1.status
    assert_equal :stripe, subscription_1.provider
    assert_equal :month, subscription_1.interval
    assert_equal "su_1", subscription_1.external_id
    assert_equal 999, subscription_1.amount_in_cents

    assert_equal 1, user_2.subscriptions.count
    subscription_2 = user_2.subscriptions.first
    assert_equal :active, subscription_2.status
    assert_equal :stripe, subscription_2.provider
    assert_equal :year, subscription_2.interval
    assert_equal "su_2", subscription_2.external_id
    assert_equal 777, subscription_2.amount_in_cents
  end

  test "creates subscription for subscriptions only in Stripe with unknown stripe customer but known email" do
    user_1 = create :user, email: 'user1@test.org', stripe_customer_id: nil
    user_2 = create :user, email: 'user2@test.org', stripe_customer_id: nil

    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?expand%5B%5D=data.customer&limit=100&query=status:'active'").
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
              "customer": {
                "id": "cus_1",
                "email": "user1@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999,
                      "product": Exercism.secrets.stripe_recurring_product_id,
                      "recurring": {
                        "interval": "month"
                      }
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
              "customer": {
                "id": "cus_2",
                "email": "user2@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_2",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_2",
                      "object": "price",
                      "unit_amount": 777,
                      "product": Exercism.secrets.stripe_premium_product_id,
                      "recurring": {
                        "interval": "month"
                      }
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

    refute Payments::Subscription.exists?

    Payments::Stripe::Subscription::SyncAll.()

    assert_equal 2, Payments::Subscription.count

    assert_equal "cus_1", user_1.reload.stripe_customer_id
    assert_equal 1, user_1.subscriptions.count
    subscription_1 = user_1.subscriptions.first
    assert_equal :active, subscription_1.status
    assert_equal :stripe, subscription_1.provider
    assert_equal "su_1", subscription_1.external_id
    assert_equal 999, subscription_1.amount_in_cents

    assert_equal "cus_2", user_2.reload.stripe_customer_id
    assert_equal 1, user_2.subscriptions.count
    subscription_2 = user_2.subscriptions.first
    assert_equal :active, subscription_2.status
    assert_equal :stripe, subscription_2.provider
    assert_equal "su_2", subscription_2.external_id
    assert_equal 777, subscription_2.amount_in_cents
  end

  test "gracefully handles subscriptions only in Stripe that can't be linked to a user" do
    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?expand%5B%5D=data.customer&limit=100&query=status:'active'").
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
              "customer": {
                "id": "cus_1",
                "email": "user1@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999,
                      "product": Exercism.secrets.stripe_recurring_product_id,
                      "recurring": {
                        "interval": "month"
                      }
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

    refute Payments::Subscription.exists?

    Payments::Stripe::Subscription::SyncAll.()

    refute Payments::Subscription.exists?
  end

  test "does not change subscriptions with matching Stripe status" do
    user_1 = create :user, stripe_customer_id: "cus_1"
    user_2 = create :user, stripe_customer_id: "cus_2"

    subscription_1 = create :payments_subscription, user: user_1, external_id: "su_1", amount_in_cents: 999,
      updated_at: Time.utc(2022, 3, 18), status: :active
    subscription_2 = create :payments_subscription, user: user_2, external_id: "su_2", amount_in_cents: 777,
      updated_at: Time.utc(2022, 4, 22), status: :active

    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?expand%5B%5D=data.customer&limit=100&query=status:'active'").
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
              "customer": {
                "id": "cus_1",
                "email": "user1@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999,
                      "product": Exercism.secrets.stripe_recurring_product_id,
                      "recurring": {
                        "interval": "month"
                      }
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
              "customer": {
                "id": "cus_2",
                "email": "user2@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_2",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_2",
                      "object": "price",
                      "unit_amount": 777,
                      "product": Exercism.secrets.stripe_premium_product_id,
                      "recurring": {
                        "interval": "month"
                      }
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

    assert_equal 2, Payments::Subscription.count

    Payments::Stripe::Subscription::SyncAll.()

    assert_equal 2, Payments::Subscription.count
    assert_equal :active, subscription_1.reload.status
    assert_equal :active, subscription_2.reload.status
    assert_equal Time.utc(2022, 3, 18), subscription_1.updated_at
    assert_equal Time.utc(2022, 4, 22), subscription_2.updated_at
  end

  test "updates status to match Stripe status" do
    user_1 = create :user, stripe_customer_id: "cus_1"
    user_2 = create :user, stripe_customer_id: "cus_2"

    subscription_1 = create :payments_subscription, user: user_1, external_id: "su_1", amount_in_cents: 999,
      updated_at: Time.utc(2022, 3, 18), status: :overdue
    subscription_2 = create :payments_subscription, user: user_2, external_id: "su_2", amount_in_cents: 777,
      updated_at: Time.utc(2022, 4, 22), status: :active

    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?expand%5B%5D=data.customer&limit=100&query=status:'active'").
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
              "customer": {
                "id": "cus_1",
                "email": "user1@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999,
                      "product": Exercism.secrets.stripe_recurring_product_id,
                      "recurring": {
                        "interval": "month"
                      }
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
              "customer": {
                "id": "cus_2",
                "email": "user2@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_2",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_2",
                      "object": "price",
                      "unit_amount": 777,
                      "product": Exercism.secrets.stripe_premium_product_id,
                      "recurring": {
                        "interval": "month"
                      }
                    },
                    "subscription": "sub_2"
                  }
                ],
                "has_more": false,
                "url": "/v1/subscription_items?subscription=sub_2"
              },
              "status": "unpaid"
            }
          ]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    assert_equal 2, Payments::Subscription.count

    Payments::Stripe::Subscription::SyncAll.()

    assert_equal 2, Payments::Subscription.count
    assert_equal :active, subscription_1.reload.status
    assert_equal :canceled, subscription_2.reload.status
  end

  test "deactivates subscriptions that are not active in Stripe" do
    user_1 = create :user, stripe_customer_id: "cus_1"
    user_2 = create :user, stripe_customer_id: "cus_2"

    subscription_1 = create :payments_subscription, user: user_1, external_id: "su_1", amount_in_cents: 999,
      updated_at: Time.utc(2022, 3, 18), status: :active
    subscription_2 = create :payments_subscription, user: user_2, external_id: "su_2", amount_in_cents: 777,
      updated_at: Time.utc(2022, 4, 22), status: :active

    stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?expand%5B%5D=data.customer&limit=100&query=status:'active'").
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
              "customer": {
                "id": "cus_1",
                "email": "user1@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_1",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_1",
                      "object": "price",
                      "unit_amount": 999,
                      "product": Exercism.secrets.stripe_recurring_product_id,
                      "recurring": {
                        "interval": "month"
                      }
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
              "customer": {
                "id": "cus_2",
                "email": "user2@test.org"
              },
              "items": {
                "object": "list",
                "data": [
                  {
                    "id": "si_2",
                    "object": "subscription_item",
                    "price": {
                      "id": "p_2",
                      "object": "price",
                      "unit_amount": 999,
                      "product": Exercism.secrets.stripe_premium_product_id,
                      "recurring": {
                        "interval": "month"
                      }
                    },
                    "subscription": "sub_2"
                  }
                ],
                "has_more": false,
                "url": "/v1/subscription_items?subscription=sub_2"
              },
              "status": "canceled"
            }
          ]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    assert_equal 2, Payments::Subscription.count
    assert_equal :active, subscription_1.reload.status
    assert_equal :active, subscription_2.reload.status

    Payments::Stripe::Subscription::SyncAll.()

    assert_equal 2, Payments::Subscription.count
    assert_equal :active, subscription_1.reload.status
    assert_equal :canceled, subscription_2.reload.status
  end

  [
    ["active", :active],
    ["trialing", :active],
    ["incomplete", :overdue],
    ["past_due", :overdue],
    ["canceled", :canceled],
    ["unpaid", :canceled],
    ["incomplete_expired", :canceled]
  ].each do |(stripe_status, new_status)|
    test "updates subscription status to #{new_status} when Stripe status is #{stripe_status}" do
      user = create :user, stripe_customer_id: "cus_1"

      subscription = create :payments_subscription, user:, external_id: "su_1", amount_in_cents: 999,
        updated_at: Time.utc(2022, 3, 18), status: :active

      stub_request(:get, "https://api.stripe.com/v1/subscriptions/search?expand%5B%5D=data.customer&limit=100&query=status:'active'").
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
                "customer": {
                  "id": "cus_1",
                  "email": "user1@test.org"
                },
                "items": {
                  "object": "list",
                  "data": [
                    {
                      "id": "si_1",
                      "object": "subscription_item",
                      "price": {
                        "id": "p_1",
                        "object": "price",
                        "unit_amount": 999,
                        "product": Exercism.secrets.stripe_recurring_product_id,
                        "recurring": {
                          "interval": "month"
                        }
                      },
                      "subscription": "sub_1"
                    }
                  ],
                  "has_more": false,
                  "url": "/v1/subscription_items?subscription=sub_1"
                },
                "status": stripe_status
              }
            ]
          }.to_json,
          headers: { 'Content-Type': 'application/json' }
        )

      assert_equal :active, subscription.status

      Payments::Stripe::Subscription::SyncAll.()

      assert_equal new_status, subscription.reload.status
    end
  end
end
