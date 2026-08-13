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

      # NOTE: user_tracks.reputation is maintained by an after_commit on
      # User::ReputationToken itself, so that deletions decrement it too.
    rescue ActiveRecord::RecordNotUnique
      return klass.find_by!(user:, uniqueness_key: token.uniqueness_key)
    end
  rescue NoPublishedSolutionForReputationTokenError
    # Don't create a token if the user has subsequently unpublished the solution
  end
end
