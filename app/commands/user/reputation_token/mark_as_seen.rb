class User::ReputationToken::MarkAsSeen
  include Mandate

  initialize_with :token

  def call
    return if token.seen?

    token.seen!
    User::ResetCache.(token.user)
  end
end
