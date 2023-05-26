class AssembleActiveSubscription
  include Mandate

  initialize_with :user, :product

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
  def subscription
    case product.to_sym
    when :donation
      user.current_active_donation_subscription
    when :premium
      user.current_active_premium_subscription
    end
  end
end
