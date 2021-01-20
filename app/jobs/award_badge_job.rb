class AwardBadgeJob < ApplicationJob
  queue_as :default

  discard_on BadgeCriteriaNotFulfilledError

  def perform(user, badge_slug)
    User::AcquiredBadge::Create.(user, badge_slug)
  end
end
