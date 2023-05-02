module Badges
  class InsiderBadge < Badge
    seed "Insider",
      :ultimate,
      'insiders',
      'Member of Exercism Insiders'

    def award_to?(user) = VALID_INSIDERS_STATUSES.include?(user.insiders_status)
    def send_email_on_acquisition? = true

    VALID_INSIDERS_STATUSES = %i[active active_lifetime].freeze
    private_constant :VALID_INSIDERS_STATUSES
  end
end
