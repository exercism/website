# The goal of this job is to re-sync sponsors to ensure
# that our payment and subscription data are correct
class SyncSponsorsJob < ApplicationJob
  queue_as :dribble

  def perform
    Donations::Github::Sponsorship::SyncAll.()
    Donations::Stripe::Subscription::SyncAll.()
  end
end
