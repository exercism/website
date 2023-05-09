class User::ResetCache
  include Mandate

  initialize_with :user

  def call
    # Don't call user.update! here
    user.data.update!(cache:)
    cache
  end

  private
  memoize
  def cache
    {
      has_unrevealed_testimonials?: user.mentor_testimonials.unrevealed.exists?,
      has_unrevealed_badges?: user.acquired_badges.unrevealed.exists?,
      has_unseen_reputation_tokens?: user.reputation_tokens.unseen.exists?
    }
  end
end
