module Badges
  class BardBadge < Badge
    seed "Bard",
      :ultimate,
      'bard',
      'Created an exercise story'

    def award_to?(user)
      return false unless user.github_username

      BARDS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition?
      true
    end

    BARDS = %w[
      todo
    ].freeze
    private_constant :BARDS
  end
end
