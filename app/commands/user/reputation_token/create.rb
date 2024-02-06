class User::ReputationToken::Create
  include Mandate

  queue_as :reputation

  initialize_with :user, :type, params: Mandate::KWARGS

  def call
    return if user.system? || user.ghost?

    klass = "user/reputation_tokens/#{type}_token".camelize.constantize

    klass.new(
      user:,
      params:
    ).tap do |token|
      token.save!

      AwardBadgeJob.perform_later(user, :contributor, context: token)
      User::ReputationPeriod::MarkForToken.(token)
      User::ResetCache.defer(user, :has_unseen_reputation_tokens?)

      user_track = token.track.present? && UserTrack.find_by(user:, track: token.track)
      UserTrack::UpdateReputation.(user_track) if user_track.present?
      User::Profile::InvalidateCloudfrontItem.(user) if user.profile?
    rescue ActiveRecord::RecordNotUnique
      return klass.find_by!(user:, uniqueness_key: token.uniqueness_key)
    end
  end
end
