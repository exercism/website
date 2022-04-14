class AwardBadgeJob < ApplicationJob
  queue_as :reputation

  discard_on BadgeCriteriaNotFulfilledError

  def perform(user, badge_slug, send_email: true, **kwargs)
    User::AcquiredBadge::Create.(user, badge_slug, send_email:, context: kwargs)
  end
end
