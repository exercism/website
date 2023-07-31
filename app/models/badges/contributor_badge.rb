module Badges
  class ContributorBadge < Badge
    seed "Contributor",
      :ultimate,
      :contributors,
      'Contributed to Exercism'

    def self.worth_queuing?(reputation_token:)
      CATEGORIES.include?(reputation_token.category)
    end

    def award_to?(user)
      User::ReputationToken.where(category: CATEGORIES, user_id: user.id).exists?
    end

    def send_email_on_acquisition? = false
    def notification_key = :added_to_contributors_page

    CATEGORIES = %i[building maintaining mentoring authoring].freeze
    private_constant :CATEGORIES
  end
end
