# The goal of this job is to re-sync sponsors to ensure
# that our payment and subscription data are correct
class SyncPaymentsJob < ApplicationJob
  queue_as :dribble

  def perform
    Payments::Github::Sponsorship::SyncAll.()
    Payments::Stripe::Subscription::SyncAll.()
    Payments::Stripe::Payment::SyncAll.()
    Payments::Subscription::CancelPending.()
  end
end
