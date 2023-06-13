class User::ResetCache
  include Mandate

  initialize_with :user, :key

  def call
    # Some of these queries are really slow
    # so we don't want to wrap them in a pesimistic lock.
    # As user-data has an optimistic lock, it's not necessary either

    # Just update the single cache value, rather than
    # overriding the whole thing
    new_value = send("value_for_#{key}")

    # Change the lines below this once we move to Mysql 8
    # User::Data.where(id: user.data.id).update_all(
    #   cache: Arel.sql(%{
    #      JSON_MERGE_PATCH(
    #       COALESCE(`cache`, "{}"),
    #       '{"#{key}": #{new_value}}'
    #      )
    #   })
    # )

    User::Data.transaction do
      data = User::Data.lock(true).find(user.data.id)
      data.cache[key] = new_value
      data.save!
    end
  end

  private
  def value_for_has_unrevealed_testimonials? = user.mentor_testimonials.unrevealed.exists?
  def value_for_has_unrevealed_badges? = user.acquired_badges.unrevealed.exists?
  def value_for_has_unseen_reputation_tokens? = user.reputation_tokens.unseen.exists?
end
