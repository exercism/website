module Badges
  class BegetterBadge < Badge
    seed "Begetter",
      :ultimate,
      'begetter',
      'Significantly contributed to a Track before launch'

    def award_to?(user)
      return false unless user.github_username

      BEGETTERS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition?
      true
    end

    BEGETTERS = %w[
      todo
    ].freeze
    private_constant :BEGETTERS
  end
end
