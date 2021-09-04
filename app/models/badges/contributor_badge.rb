module Badges
  class ContributorBadge < Badge
    seed "Contributor",
      :ultimate,
      :contributors,
      'Awarded for contributing to Exercism'

    def award_to?(user)
      User::ReputationToken.where(
        category: %i[building maintaining mentoring authoring],
        user: user.id
      ).exists?
    end

    def send_email_on_acquisition?
      false
    end

    def notification_key
      :added_to_contributors_page
    end
  end
end
