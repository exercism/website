module Badges
  class LifetimeInsiderBadge < Badge
    seed "Lifetime Insider",
      :legendary,
      'lifetime-insiders',
      'One of the Lifetime Insiders'

    def award_to?(user) = user.insiders_status_active_lifetime?
    def send_email_on_acquisition? = true
  end
end
