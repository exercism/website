class AwardBadgeJob < ApplicationJob
  queue_as :reputation

  discard_on BadgeCriteriaNotFulfilledError

  def self.perform_later(user, badge_slug, send_email: true, **context)
    return unless badge(badge_slug).worth_queuing?(**context)

    super(user, badge_slug, send_email:)
  end

  def perform(user, badge_slug, send_email: true)
    User::AcquiredBadge::Create.(user, badge_slug, send_email:)
  end

  def self.badge(badge_slug)
    "Badges::#{badge_slug.to_s.camelize}Badge".constantize
  end
end
