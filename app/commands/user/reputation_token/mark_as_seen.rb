class User::ReputationToken::MarkAsSeen
  include Mandate

  initialize_with :token

  def call
    return if token.seen?

    token.seen!
    User::ResetCache.defer(token.user, :has_unseen_reputation_tokens?)
  end
end
