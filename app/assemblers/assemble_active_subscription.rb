class AssembleActiveSubscription
  include Mandate

  initialize_with :user

  def call
    return { subscription: nil } if subscription.blank?

    {
      subscription: {
        amount_in_cents: subscription.amount_in_cents
      }
    }
  end

  private
  def subscription
    user.active_subscription
  end
end
