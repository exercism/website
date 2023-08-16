class AwardTrophyJob < ApplicationJob
  queue_as :reputation

  discard_on TrophyCriteriaNotFulfilledError

  def self.perform_later(user, track, slug, send_email: true, context: nil)
    return unless self.worth_queuing?(track, slug, context:)

    super(user, track, slug, send_email:)
  end

  def perform(user, track, slug, send_email: true)
    UserTrack::AcquiredTrophy::Create.(user, track, slug, send_email:)
  end

  def self.worth_queuing?(track, slug, context:)
    trophy = "Track::Trophies::#{slug.to_s.camelize}Trophy".safe_constantize

    # Don't queue the job if the trophy is not enabled for this track
    return false unless trophy.enabled_for_track?(track)

    # Queue the job if there is no context to conditionally
    # determine if the job needs to be queued
    return true if context.blank?

    context_key = context.class.base_class.name.demodulize.underscore
    args = { context_key => context }
    trophy.worth_queuing?(**args.symbolize_keys)
  end
end
