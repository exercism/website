module Badges
  class ContributorBadge < Badge
    seed "Contributor",
      :legendary,
      :contributors,
      'Awarded for contributing to Exercism'

    def award_to?(user)
      User::ReputationToken.where(
        category: %i[building maintaining mentoring authoring],
        user: user.id
      ).exists?
    end

    def awarded_to!(user)
      User::Notification::Create.(user, :added_to_contributors_page, {})
    end
  end
end
