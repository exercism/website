class AwardBadgeJob < ApplicationJob
  queue_as :reputation

  discard_on BadgeCriteriaNotFulfilledError

  def self.perform_later(user, badge_slug, send_email: true, context: nil)
    return unless self.worth_queuing?(badge_slug, context:)

    super(user, badge_slug, send_email:)
  end

  def perform(user, badge_slug, send_email: true)
    User::AcquiredBadge::Create.(user, badge_slug, send_email:)
  end

  def self.worth_queuing?(badge_slug, context:)
    return true if context.blank?

    context_key = context.class.base_class.name.demodulize.underscore
    badge = "Badges::#{badge_slug.to_s.camelize}Badge".safe_constantize
    badge.worth_queuing?(**{ context_key => context }.symbolize_keys)
  end
end
