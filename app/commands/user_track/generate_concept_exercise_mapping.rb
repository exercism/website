class UserTrack
  class GenerateConceptExerciseMapping
    include Mandate

    initialize_with :user_track

    def call
      return {} if user_track.nil?

      taught_counts =
        Exercise::TaughtConcept.
          where(exercise_id: user_track.track.concept_exercises).
          group(:track_concept_id).
          count
      taught_counts.default = 0

      prereq_counts =
        Exercise::Prerequisite.
          where(exercise_id: user_track.track.practice_exercises).
          group(:track_concept_id).
          count
      prereq_counts.default = 0

      solved_taught_counts =
        Exercise::TaughtConcept.where(exercise_id:
          Solution.where(exercise_id: user_track.track.concept_exercises).completed.select(:exercise_id)).
          group(:track_concept_id).
          count
      solved_taught_counts.default = 0

      solved_prereq_counts =
        Exercise::Prerequisite.where(exercise_id:
          Solution.where(exercise_id: user_track.track.practice_exercises).completed.select(:exercise_id)).
          group(:track_concept_id).
          count
      solved_prereq_counts.default = 0

      user_track.track.concepts.each_with_object({}) do |concept, hash|
        hash[concept.slug] = {
          exercises: prereq_counts[concept.id] + taught_counts[concept.id],
          exercises_completed: solved_prereq_counts[concept.id] + solved_taught_counts[concept.id]
        }
      end
    end
  end
end
