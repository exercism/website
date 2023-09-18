class Mentor::CalculateSatisfactionPercentage
  include Mandate

  initialize_with :mentor

  def call
    User.connection.select_value(mentor_satisfaction_percentage_sql)
  end

  private
  def mentor_satisfaction_percentage_sql
    # Dividing by zero explodes, but dividing by null returns null, so we guard
    # using nullif, which is fine for our purposes here.
    "SELECT CEIL((#{rated_acceptable_or_better_count_sql}) / NULLIF((#{rated_count_sql}),0) * 100) as val"
  end

  def rated_acceptable_or_better_count_sql
    Arel.sql(Mentor::Discussion.where(mentor:, rating: %i[acceptable good great]).select("COUNT(*)").to_sql)
  end

  def rated_count_sql
    Arel.sql(Mentor::Discussion.where(mentor:).where.not(rating: nil).select("COUNT(*)").to_sql)
  end
end
