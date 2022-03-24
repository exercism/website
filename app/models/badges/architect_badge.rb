module Badges
  class ArchitectBadge < Badge
    seed "Architect",
      :ultimate,
      'architect',
      'Designed a track syllabus'

    def award_to?(user)
      return false unless user.github_username

      ARCHITECTS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition?
      true
    end

    ARCHITECTS = %w[
      todo
    ].freeze
    private_constant :ARCHITECTS
  end
end
