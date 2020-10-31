class UserTrack
  class GenerateConceptExerciseMapping
    include Mandate

    initialize_with :user_track

    def call
      return {} if user_track.nil?

      concept_exercise_mapping =
        user_track.
          track.
          exercises.
          # includes(:taught_concepts, :prerequisites). <-- How to optimize? raises error d/t practice exercise
          each_with_object({}) do |exercise, hash|
            concepts = exercise.practice_exercise? ? exercise.prerequisites : exercise.taught_concepts

            concepts.to_a.each do |concept|
              slug = concept.slug
              hash[slug] ||= { exercises: 0, exercises_completed: 0 }
              hash[slug][:exercises] += 1
            end
          end

      concept_exercise_mapping.tap do |hash|
        user_track.solutions.completed.each do |solution|
          exercise = solution.exercise
          concepts = exercise.practice_exercise? ? exercise.prerequisites : exercise.taught_concepts
          concepts.to_a.each do |concept|
            slug = concept.slug
            hash[slug][:exercises_completed] += 1
          end
        end
      end

      # prereq_counts = Exercise::Prerequisite.where(exercise_id: user_track.track.practice_exercises).group(:id).count
      # prereq_counts.default = 0
      # taught_counts = Exercise::TaughtConcept.where(exercise_id: user_track.track.concept_exercises).group(:id).count
      # taught_counts.default = 0
      #
      # solved_prereq_counts =
      #   Exercise::Prerequisite.
      #     where(exercise:
      #       Solution.where(exercise_id: user_track.track.practice_exercises).completed.select(:exercise_id)
      #     ).
      #     group(:id).
      #     count
      # solved_prereq_counts.default = 0
      # solved_taught_counts =
      #   Exercise::TaughtConcept.
      #     where(exercise:
      #       Solution.where(exercise_id: user_track.track.concept_exercises).completed.select(:exercise_id)
      #     ).
      #     group(:id).
      #     count
      # solved_taught_counts.default = 0

      # user_track.track.concepts.to_a.each_with_object({}) do |concept, hash|
      #   hash[concept.slug] ||= {
      #     exercises: prereq_counts[concept.id] + taught_counts[concept.id],
      #     exercises_completed: solved_prereq_counts[concept.id] + solved_taught_counts[concept.id]
      #   }
      # end
    end
  end
end
