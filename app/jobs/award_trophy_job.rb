class AwardTrophyJob < ApplicationJob
  queue_as :reputation

  discard_on TrophyCriteriaNotFulfilledError

  def self.perform_later(user, track, category, slug, send_email: true, context: nil)
    return unless self.worth_queuing?(user, track, category, slug, context:)

    super(user, track, category, slug, send_email:)
  end

  def perform(user, track, category, slug, send_email: true)
    UserTrack::AcquiredTrophy::Create.(user, track, category, slug, send_email:)
  end

  def self.worth_queuing?(user, track, category, slug, context:)
    return true if category == :general

    args = { user:, track: }
    args[context.class.base_class.name.demodulize.underscore] = context if context.present?

    badge = "Track::Trophies::#{category.to_s.camelize}::#{slug.to_s.camelize}Trophy".safe_constantize
    badge.worth_queuing?(**args.symbolize_keys)
  end
end
