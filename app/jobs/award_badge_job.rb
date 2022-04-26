class AwardBadgeJob < ApplicationJob
  queue_as :reputation

  discard_on BadgeCriteriaNotFulfilledError

  def self.perform_later(user, badge_slug, send_email: true, context: nil)
    return unless badge(badge_slug).worth_queuing?(**worth_queuing_context(context))

    super(user, badge_slug, send_email:)
  end

  def perform(user, badge_slug, send_email: true)
    User::AcquiredBadge::Create.(user, badge_slug, send_email:)
  end

  def self.badge(badge_slug)
    "Badges::#{badge_slug.to_s.camelize}Badge".constantize
  end

  def self.worth_queuing_context(context)
    return {} if context.nil?

    { context.class.base_class.name.demodulize.underscore => context }.symbolize_keys
  end
end
