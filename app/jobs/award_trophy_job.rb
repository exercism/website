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
    trophy = "Track::Trophies::#{category.to_s.camelize}::#{slug.to_s.camelize}Trophy".safe_constantize

    # Don't queue the job if the badge is not enabled for this track
    return false unless trophy.enabled_for_track?(track)

    # Queue the job if there is no context to conditionally
    # determine if the job needs to be queued
    return true if context.blank?

    context_key = context.class.base_class.name.demodulize.underscore
    args = { context_key => context }
    trophy.worth_queuing?(**args.symbolize_keys)
  end
end
