class Mentor::UpdateSatisfactionRating
  include Mandate

  initialize_with :mentor

  def call
    # We're updating in a single query instead of two queries to avoid race-conditions
    # and using read_committed to avoid deadlocks
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      User::Data.where(user_id: mentor.id).update_all("mentor_satisfaction_percentage = #{mentor_satisfaction_percentage_sql}")
    end

    User::UpdateMentorRoles.(mentor.reload)
  end

  private
  def mentor_satisfaction_percentage_sql
    # Dividing by zero explodes, but dividing by null returns null, so we guard
    # using nullif, which is fine for our purposes here.
    "CEIL((#{rated_acceptable_or_better_count_sql}) / NULLIF((#{rated_count_sql}),0) * 100)"
  end

  def rated_acceptable_or_better_count_sql
    Arel.sql(Mentor::Discussion.where(mentor:, rating: %i[acceptable good great]).select("COUNT(*)").to_sql)
  end

  def rated_count_sql
    Arel.sql(Mentor::Discussion.where(mentor:).where.not(rating: nil).select("COUNT(*)").to_sql)
  end
end
