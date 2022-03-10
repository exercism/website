class AwardBadgeJob < ApplicationJob
  queue_as :reputation

  discard_on BadgeCriteriaNotFulfilledError

  def perform(user, badge_slug, skip_email: false)
    User::AcquiredBadge::Create.(user, badge_slug, skip_email:)
  end
end
