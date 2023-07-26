class Track::UpdateNumConcepts
  include Mandate

  initialize_with :track

  def call
    # We're updating in a single query instead of two queries to avoid race-conditions
    # and using read_committed to avoid deadlocks
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      Track.where(id: track.id).update_all("num_concepts = (#{sql})")
    end
  end

  memoize
  def sql
    Arel.sql(
      Exercise::TaughtConcept.joins(:exercise).
        where(exercise: { track: track.id, status: %i[beta active] }).
        select("COUNT(DISTINCT(track_concept_id))").
        to_sql
    )
  end
end
