# Ensure that our local Stripe subscriptions match the actual Stripe subscriptions
class Payments::Stripe::Subscription::SyncAll
  include Mandate

  def call
    create_subscriptions!
    update_subscriptions!
    deactivate_subscriptions!
  end

  def create_subscriptions!
    missing_active_subscription_ids = active_stripe_subscription_ids - local_subscription_ids
    missing_active_subscription_ids.each do |subscription_id|
      stripe_subscription = active_stripe_subscriptions[subscription_id]

      user = subscription_user(stripe_subscription)
      next unless user

      Payments::Stripe::Subscription::Create.(user, stripe_subscription)
    end
  end

  def update_subscriptions!
    subscription_ids = local_subscription_ids & active_stripe_subscription_ids
    subscription_ids.each do |subscription_id|
      subscription = local_subscriptions[subscription_id]
      stripe_subscription = active_stripe_subscriptions[subscription_id]

      update_subscription_status(subscription, stripe_subscription)
    end
  end

  def deactivate_subscriptions!
    inactive_subscription_ids = local_subscription_ids - active_stripe_subscription_ids
    inactive_subscription_ids.each do |subscription_id|
      subscription = local_subscriptions[subscription_id]
      stripe_subscription = Stripe::Subscription.retrieve(subscription_id)

      update_subscription_status(subscription, stripe_subscription)
    end
  end

  memoize
  def active_stripe_subscriptions
    stripe_subscriptions = Stripe::Subscription.search({
      query: "status:'active'",
      limit: 100,
      expand: ["data.customer"]
    })

    stripe_subscriptions.auto_paging_each.index_by(&:id)
  end

  memoize
  def active_stripe_subscription_ids = active_stripe_subscriptions.keys

  memoize
  def local_subscriptions = Payments::Subscription.stripe.find_each.index_by(&:external_id)

  memoize
  def local_subscription_ids = local_subscriptions.keys

  def update_subscription_status(subscription, stripe_subscription)
    status = SUBSCRIPTION_STATUSES.fetch(stripe_subscription&.status, :canceled)

    subscription.update!(status:)

    Payments::Subscription::Cancel.(subscription) if subscription.canceled?
  end

  def subscription_user(stripe_subscription)
    stripe_user = User.with_data.find_by(data: { stripe_customer_id: stripe_subscription.customer.id })
    return stripe_user if stripe_user

    User.find_by(email: stripe_subscription.customer.email)&.tap do |user|
      user.update!(stripe_customer_id: stripe_subscription.customer.id)
    end
  end

  SUBSCRIPTION_STATUSES = {
    "active" => :active,
    "trialing" => :active,
    "incomplete" => :overdue,
    "past_due" => :overdue,
    "canceled" => :canceled,
    "unpaid" => :canceled,
    "incomplete_expired" => :canceled
  }.freeze
  private_constant :SUBSCRIPTION_STATUSES
end
