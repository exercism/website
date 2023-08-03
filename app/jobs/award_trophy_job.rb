class AwardTrophyJob < ApplicationJob
  queue_as :reputation

  discard_on TrophyCriteriaNotFulfilledError

  def self.perform_later(user, track, category, slug, send_email: true, context: nil)
    return unless self.worth_queuing?(track, category, slug, context:)

    super(user, track, category, slug, send_email:)
  end

  def perform(user, track, category, slug, send_email: true)
    UserTrack::AcquiredTrophy::Create.(user, track, category, slug, send_email:)
  end

  def self.worth_queuing?(track, category, slug, context:)
    # General trophies apply to _all_ tracks, so there won't be any track filtering.
    # If the context is also empty, there is no possibility of the trophy not being
    # worth queuing
    return true if category == :general && context.empty?

    args = { track: }
    args[context.class.base_class.name.demodulize.underscore] = context if context.present?

    badge = "Track::Trophies::#{category.to_s.camelize}::#{slug.to_s.camelize}Trophy".safe_constantize
    badge.worth_queuing?(**args.symbolize_keys)
  end
end
