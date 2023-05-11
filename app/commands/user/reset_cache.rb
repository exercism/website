class User::ResetCache
  include Mandate

  initialize_with :user, :key

  def call
    # Some of these queries are really slow
    # so we don't want to wrap them in a pesimistic lock.
    # As user-data has an optimistic lock, it's not necessary either

    # Don't call user.update! here
    user.data.update!(cache:)
    cache
  end

  private
  memoize
  def cache
    user.cache.tap do |c|
      c[key.to_s] = send("value_for_#{key}")
    end
  end

  def value_for_has_unrevealed_testimonials? = user.mentor_testimonials.unrevealed.exists?
  def value_for_has_unrevealed_badges? = user.acquired_badges.unrevealed.exists?
  def value_for_has_unseen_reputation_tokens? = user.reputation_tokens.unseen.exists?
end
