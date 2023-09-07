class AssembleCurrentSubscription
  include Mandate

  initialize_with :user

  def call
    return { subscription: nil } if user.blank? || subscription.blank?

    {
      subscription: {
        provider: subscription.provider,
        interval: subscription.interval,
        amount_in_cents: subscription.amount_in_cents
      }
    }
  end

  private
  memoize
  def subscription = user.current_subscription
end
