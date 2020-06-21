class AwardBadgeJob < ApplicationJob
  queue_as :default

  discard_on BadgeCriteriaNotFulfilledError

  def perform(user, badge_slug)
    Badge::Create.(user, badge_slug)
  end
end
