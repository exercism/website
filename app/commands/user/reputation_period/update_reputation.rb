class User::ReputationPeriod::UpdateReputation
  include Mandate

  queue_as :reputation

  initialize_with :period

  def call
    if should_delete?
      period.destroy
    else
      recalculate!
    end

    User::InsidersStatus::TriggerUpdate.(period.user)
  end

  private
  # If the category is all, then we need to guard against
  # the only tokens left being publishing, in which case someone
  # shouldn't appear on the leaderboard any more
  def should_delete?
    return false unless period.any_category?

    tokens = User::ReputationToken.where(user_id: period.user_id)
    tokens = filter_track!(tokens)
    tokens = filter_period!(tokens)
    tokens = tokens.where.not(category: :publishing)
    !tokens.exists? # Don't use empty? here - it's slower.
  end

  def recalculate!
    # TODO: Guard as to whether this is still valid
    tokens = User::ReputationToken.where(user_id: period.user_id)
    tokens = filter_track!(tokens)
    tokens = filter_period!(tokens)
    tokens = filter_category!(tokens)

    # Update the period row. We do this all in one SQL command
    # to avoid any race conditions caused by a new token being added.
    update_reputation_sql = tokens.select("SUM(value)").to_sql
    update_num_tokens_sql = tokens.select("COUNT(*)").to_sql

    # Use a read_committed transaction to free non-matching rows
    # and avoid deadlocks
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      User::ReputationPeriod.where(id: period.id).
        update_all(%{
          dirty = false,
          reputation = IFNULL((#{update_reputation_sql}), 0),
          num_tokens = IFNULL((#{update_num_tokens_sql}), 0)
        })
    end

    # Delete any rows that have been taken down to zero
    # Ensure we guard for {dirty: false} here in case something
    # else is making it dirty again. This saves us having to do locking.
    User::ReputationPeriod.where(id: period.id, reputation: 0, dirty: false).delete_all
  end

  def filter_track!(tokens)
    return tokens unless period.about_track?

    tokens.where(track_id: period.track_id)
  end

  def filter_period!(tokens)
    return tokens if period.forever?

    if period.year?
      # If today is 29th May 2022, have >= 30th May 2020
      tokens.where("earned_on >= ?", Date.current - 364.days)
    elsif period.month?
      tokens.where("earned_on >= ?", Date.current - 29.days)
    elsif period.week?
      tokens.where("earned_on >= ?", Date.current - 6.days)
    else
      tokens
    end
  end

  def filter_category!(tokens)
    return tokens if period.any_category?

    tokens.where(category: period.category)
  end
end
