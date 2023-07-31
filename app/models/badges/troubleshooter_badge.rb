module Badges
  class TroubleshooterBadge < Badge
    seed "Troubleshooter",
      :legendary,
      'troubleshooter',
      'Helped troubleshoot issues'

    def award_to?(user)
      return false unless user.github_username

      TROUBLESHOOTERS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition? = true

    TROUBLESHOOTERS = %w[
      angelikatyborska
      ihid
      kotp
      kytrinyx
      nobbz
      sleeplessbyte
    ].freeze
    private_constant :TROUBLESHOOTERS
  end
end
