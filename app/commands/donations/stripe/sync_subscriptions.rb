# Ensure that our local Stripe subscriptions match the actual Stripe subscriptions
class Donations::Stripe::SyncSubscriptions
  include Mandate

  def call
    create_subscriptions!
    deactivate_subscriptions!
  end

  def create_subscriptions!
    missing_active_subscription_ids = active_stripe_subscription_ids - local_subscription_ids
    missing_active_subscription_ids.each do |subscription_id|
      subscription = active_stripe_subscriptions[subscription_id]

      user = User.find_by(stripe_customer_id: subscription.customer)
      next unless user

      Donations::Subscription::Create.(user, subscription)
    end
  end

  def deactivate_subscriptions!
    inactive_subscription_ids = local_subscription_ids - active_stripe_subscription_ids
    inactive_subscription_ids.each do |subscription_id|
      subscription = local_subscriptions[subscription_id]
      Donations::Subscription::Deactivate.(subscription) if subscription.active
    end
  end

  memoize
  def active_stripe_subscriptions
    subscriptions = Stripe::Subscription.search({
      query: "status:'active'",
      limit: 100
    })

    subscriptions.auto_paging_each.index_by(&:id)
  end

  memoize
  def active_stripe_subscription_ids = active_stripe_subscriptions.keys

  memoize
  def local_subscriptions = Donations::Subscription.find_each.index_by(&:stripe_id)

  memoize
  def local_subscription_ids = local_subscriptions.keys
end