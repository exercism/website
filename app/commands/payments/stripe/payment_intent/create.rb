class Payments::Stripe::PaymentIntentError < RuntimeError
end

class Payments::Stripe::PaymentIntent::Create
  include Mandate

  initialize_with :user_or_email, :type, :amount_in_cents

  def call
    if invalid_user_or_email?
      Bugsnag.notify(Payments::Stripe::PaymentIntentError.new("Invalid user or email trying to make donation: #{user_or_email}"))
      return
    end

    customer_id = user ?
      Payments::Stripe::Customer::CreateForUser.(user) :
      Payments::Stripe::Customer::CreateForEmail.(user_or_email)

    case type.to_sym
    when :subscription
      Payments::Stripe::PaymentIntent::CreateForSubscription.(customer_id, amount_in_cents)
    else
      Payments::Stripe::PaymentIntent::CreateForPayment.(customer_id, amount_in_cents)
    end
  end

  private
  def invalid_user_or_email?
    user_or_email.is_a?(User) ?
      User::BlockDomain.blocked?(user:) :
      User::BlockDomain.blocked?(email: user_or_email)
  end

  memoize
  def user
    return user_or_email if user_or_email.is_a?(User)

    User.find_by(email: user_or_email)
  end
end
