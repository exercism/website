class User::ReputationToken::MarkAsSeen
  include Mandate

  initialize_with :token

  def call
    return if token.seen?

    token.seen!
    User::ResetCache.defer(token.user)
  end
end
