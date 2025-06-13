module Badges
  class LifetimeInsiderBadge < Badge
    seed "Lifetime Insider",
      :legendary,
      'lifetime-insiders',
      'One of the Lifetime Insiders'

    def award_to?(user)
      user.reload.data.insiders_status_active_lifetime?
    end

    def send_email_on_acquisition? = true
  end
end
