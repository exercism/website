module Badges
  class InsiderBadge < Badge
    seed "Insider",
      :ultimate,
      'insiders',
      'Member of Exercism Insiders'

    def award_to?(user) = user.insiders_status_active? || user.insiders_status_active_lifetime?
    def send_email_on_acquisition? = true
  end
end
