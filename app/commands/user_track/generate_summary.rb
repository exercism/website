class UserTrack
  class GenerateSummary
    include Mandate

    initialize_with :user_track
    delegate :track, to: :user_track

    def call
      #####################
      # Populate concepts #
      #####################
      concepts = {}
      track.concepts.each do |concept|
        concept_exercises = concept_exercise_data.values.
          select { |e| e[:taught_concepts].include?(concept.slug) }.
          map { |e| e[:slug] }
        practice_exercises = practice_exercise_data.values.
          select { |e| e[:prerequisites].include?(concept.slug) }.
          map { |e| e[:slug] }

        completed_solutions = solutions_data.values.select { |s| s[:completed] }
        concept_solutions = completed_solutions.select { |s| concept_exercises.include?(s[:slug]) }
        practice_solutions = completed_solutions.select { |s| practice_exercises.include?(s[:slug]) }

        concepts[concept.slug] = UserTrack::Summary::ConceptSummary.new(
          slug: concept.slug,
          num_concept_exercises: concept_exercises.count,
          num_practice_exercises: practice_exercises.count,
          num_completed_concept_exercises: concept_solutions.count,
          num_completed_practice_exercises: practice_solutions.count
        )
      end

      {
        concepts: concepts
      }
    end

    private
    memoize
    def solutions_data
      solutions = user_track.solutions.includes(:exercise)

      solutions.each_with_object({}) do |solution, data|
        data[solution.exercise.slug] = {
          slug: solution.exercise.slug,
          submitted: solution.submitted?,
          completed: solution.completed?
        }
      end
    end

    memoize
    def concept_exercise_data
      exercises = track.concept_exercises.includes(:taught_concepts).to_a
      exercises.each_with_object({}) do |exercise, data|
        data[exercise.slug] = {
          slug: exercise.slug,
          taught_concepts: exercise.taught_concepts.map(&:slug)
        }
      end
    end

    memoize
    def practice_exercise_data
      exercises = track.practice_exercises.includes(:prerequisites).to_a

      exercises.each_with_object({}) do |exercise, data|
        data[exercise.slug] = {
          slug: exercise.slug,
          prerequisites: exercise.prerequisites.map(&:slug)
        }
      end
    end
  end
end
