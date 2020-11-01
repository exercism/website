class UserTrack
  class GenerateConceptExerciseMapping
    include Mandate

    initialize_with :user_track

    def call
      return {} unless user_track

      taught_counts =
        Exercise::TaughtConcept.
          where(exercise_id: user_track.track.concept_exercises).
          group(:track_concept_id).
          count

      prereq_counts =
        Exercise::Prerequisite.
          where(exercise_id: user_track.track.practice_exercises).
          group(:track_concept_id).
          count

      solved_taught_counts =
        Exercise::TaughtConcept.
          where(exercise_id:
            Solution.where(exercise_id: user_track.track.concept_exercises).completed.select(:exercise_id)).
          group(:track_concept_id).
          count

      solved_prereq_counts =
        Exercise::Prerequisite.
          where(exercise_id:
            Solution.where(exercise_id: user_track.track.practice_exercises).completed.select(:exercise_id)).
          group(:track_concept_id).
          count

      user_track.track.concepts.each_with_object({}) do |concept, hash|
        hash[concept.slug] = {
          exercises: prereq_counts[concept.id].to_i + taught_counts[concept.id].to_i,
          exercises_completed: solved_prereq_counts[concept.id].to_i + solved_taught_counts[concept.id].to_i
        }
      end
    end
  end
end
