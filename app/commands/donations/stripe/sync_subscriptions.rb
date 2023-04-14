# Ensure that our local Stripe subscriptions match the actual Stripe subscriptions
class Donations::Stripe::SyncSubscriptions
  include Mandate

  def call
    create_subscriptions!
    update_subscriptions!
    deactivate_subscriptions!
  end

  def create_subscriptions!
    missing_active_subscription_ids = active_stripe_subscription_ids - local_subscription_ids
    missing_active_subscription_ids.each do |subscription_id|
      subscription = active_stripe_subscriptions[subscription_id]

      user = subscription_user(subscription)
      next unless user

      Donations::Subscription::Create.(user, subscription)
    end
  end

  def update_subscriptions!
    subscription_ids = local_subscription_ids & active_stripe_subscription_ids
    subscription_ids.each do |subscription_id|
      subscription = local_subscriptions[subscription_id]
      stripe_subscription = active_stripe_subscriptions[subscription_id]

      update_subscription_status(subscription, SUBSCRIPTION_STATUSES[stripe_subscription.status])
    end
  end

  def deactivate_subscriptions!
    inactive_subscription_ids = local_subscription_ids - active_stripe_subscription_ids
    inactive_subscription_ids.each do |subscription_id|
      subscription = local_subscriptions[subscription_id]

      update_subscription_status(subscription, SUBSCRIPTION_STATUSES[subscription.status])
    end
  end

  memoize
  def active_stripe_subscriptions
    subscriptions = Stripe::Subscription.search({
      query: "status:'active'",
      limit: 100,
      expand: ["data.customer"]
    })

    subscriptions.auto_paging_each.index_by(&:id)
  end

  memoize
  def active_stripe_subscription_ids = active_stripe_subscriptions.keys

  memoize
  def local_subscriptions = Donations::Subscription.find_each.index_by(&:stripe_id)

  memoize
  def local_subscription_ids = local_subscriptions.keys

  def update_subscription_status(subscription, status)
    subscription.update(status:)

    Donations::Subscription::Deactivate.(subscription) if subscription.status == :canceled
  end

  def subscription_user(subscription)
    stripe_user = User.find_by(stripe_customer_id: subscription.customer.id)
    return stripe_user if stripe_user

    User.find_by(email: subscription.customer.email)&.tap do |user|
      user.update(stripe_customer_id: subscription.customer.id)
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
