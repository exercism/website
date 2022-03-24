module Badges
  class ToolingPioneerBadge < Badge
    seed "Tooling Pioneer",
      :ultimate,
      'tooling-pioneer',
      'Developed early prototypes of tooling for Exercism'

    def award_to?(user)
      return false unless user.github_username

      PIONEERS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition?
      true
    end

    PIONEERS = %w[
      todo
    ].freeze
    private_constant :PIONEERS
  end
end
