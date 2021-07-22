module Mentor
  class UpdateSatisfactionRating
    include Mandate

    initialize_with :mentor

    def call
      rated_acceptable_or_better_count_sql = Arel.sql(
        Mentor::Discussion.where(mentor: mentor, rating: %i[acceptable good great]).select("COUNT(*)").to_sql
      )

      rated_count_sql = Arel.sql(
        Mentor::Discussion.where(mentor: mentor).where.not(rating: nil).select("COUNT(*)").to_sql
      )

      mentor_satisfaction_percentage_sql = "CEIL((#{rated_acceptable_or_better_count_sql}) / (#{rated_count_sql}) * 100)"

      # We're updating in a single query instead of two queries to avoid race-conditions
      # and using read_committed to avoid deadlocks
      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        User.where(id: mentor.id).update_all("mentor_satisfaction_percentage = #{mentor_satisfaction_percentage_sql}")
      end
    end
  end
end
