class Exercise::TaughtConcept < ApplicationRecord
  belongs_to :exercise
  belongs_to :concept, foreign_key: :track_concept_id # rubocop:disable Rails/InverseOf

  after_save_commit do
    # We're updating in a single query instead of two queries to avoid race-conditions
    # and using read_committed to avoid deadlocks
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      concepts_count_sql = Arel.sql(
        Exercise::TaughtConcept.joins(:exercise).
          where(exercise: { track: exercise.track_id, status: %i[beta active] }).
          select("COUNT(DISTINCT(track_concept_id))").
          to_sql
      )
      Track.where(id: exercise.track_id).update_all("num_concepts = (#{concepts_count_sql})")
    end
  end
end
