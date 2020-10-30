class UserTrack
  class GenerateConceptExerciseMapping
    include Mandate

    initialize_with :user_track

    def call
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
    end
  end
end
