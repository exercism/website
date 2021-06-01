class User::ReputationPeriod
  class UpdateReputation
    include Mandate

    initialize_with :period

    def call
      @tokens = User::ReputationToken.where(user_id: period.user_id)
      filter_track!
      filter_period!
      filter_category!

      # Update the period row. We do this all in one SQL command
      # to avoid any race conditions caused by a new token being added.
      update_sql = @tokens.select("SUM(value)").to_sql
      User::ReputationPeriod.where(id: period.id).
        update_all("dirty = false, reputation = IFNULL((#{update_sql}), 0)")

      # Delete any rows that have been taken down to zero
      # Ensure we guard for {dirty: false} here in case something
      # else is making it dirty again. This saves us having to do locking.
      User::ReputationPeriod.where(id: period.id, reputation: 0, dirty: false).delete_all
    end

    def filter_track!
      return unless period.about_track?

      @tokens = @tokens.where(track_id: period.track_id)
    end

    def filter_period!
      return if period.forever?

      if period.year?
        # If today is 29th May 2022, have >= 30th May 2020
        @tokens = @tokens.where("earned_on >= ?", Date.current - 364.days)
      elsif period.month?
        @tokens = @tokens.where("earned_on >= ?", Date.current - 29.days)
      elsif period.week?
        @tokens = @tokens.where("earned_on >= ?", Date.current - 6.days)
      end
    end

    def filter_category!
      return if period.any_category?

      @tokens = @tokens.where(category: period.category)
    end
  end
end
