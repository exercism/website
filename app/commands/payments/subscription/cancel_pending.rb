# Cancel any long-standing pending subscriptions, which will be due to
# the user clicking on the subscribe button but not actually finishing
# the payment
class Payments::Subscription::CancelPending
  include Mandate

  def call
    Payments::Subscription.pending.where('created_at < ?', Time.current - 2.days).find_each do |subscription|
      Payments::Subscription::Cancel.(subscription)
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end
end
