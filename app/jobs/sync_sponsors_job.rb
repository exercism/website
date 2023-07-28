# The goal of this job is to re-sync sponsors to ensure
# that our payment and subscription data are correct
class SyncSponsorsJob < ApplicationJob
  queue_as :dribble

  def perform
    Payments::Github::Sponsorship::SyncAll.()
    Payments::Stripe::Subscription::SyncAll.()
  end
end
