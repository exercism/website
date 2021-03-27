class UserTrack
  class GenerateSummary
    include Mandate

    initialize_with :track, :user_track

    def call
      t = Time.now.to_f
      Rails.logger.info "[BM] Starting generating user summary"

      UserTrack::Summary.new(
        concepts.transform_values { |v| ConceptSummary.new(v) },
        exercises.transform_values { |v| ExerciseSummary.new(v) }
      ).tap do
        Rails.logger.info "[BM] Finished generating user summary"
        Rails.logger.info "[BM] Generating User Summary: #{Time.now.to_f - t}"
      end
    end

    memoize
    def concepts
      track.concepts.each.with_object({}) do |concept, hash|
        concept_exercises = concept_exercises_data.values.
          select { |e| e[:taught_concepts].include?(concept.slug) }.
          map { |e| e[:slug] }

        practice_exercises = practice_exercises_data.values.
          select { |e| e[:prerequisites].include?(concept.slug) }.
          map { |e| e[:slug] }

        completed_solutions = solutions_data.values.select { |s| s[:completed] }
        concept_solutions = completed_solutions.select { |s| concept_exercises.include?(s[:slug]) }
        practice_solutions = completed_solutions.select { |s| practice_exercises.include?(s[:slug]) }

        hash[concept.slug] = {
          id: concept.id,
          slug: concept.slug,
          num_concept_exercises: concept_exercises.count,
          num_practice_exercises: practice_exercises.count,
          num_completed_concept_exercises: concept_solutions.count,
          num_completed_practice_exercises: practice_solutions.count,
          unlocked: unlocked_concepts.include?(concept.slug)
        }
      end
    end

    memoize
    def exercises
      track.exercises.each.with_object({}) do |exercise, hash|
        exercise_data = exercises_data[exercise.slug]

        hash[exercise.slug] = {
          id: exercise.id,
          slug: exercise.slug,
          type: exercise.concept_exercise? ? 'concept' : 'practice',
          status: exercise_data[:status],
          unlocked: exercise_data[:unlocked],
          has_solution: exercise_data[:has_solution],
          completed: exercise_data[:completed]
        }
      end
    end

    private
    memoize
    def exercises_data
      exercises = []
      exercises += track.concept_exercises.includes(:taught_concepts, :prerequisites).to_a
      exercises += track.practice_exercises.includes(:prerequisites).to_a

      exercises.each_with_object({}) do |exercise, data|
        prerequisites = exercise.prerequisites.map(&:slug)

        solution_data = solutions_data[exercise.slug]

        # Exercises are unlocked if:
        # - They've started
        # - There are no outstanding prereqs
        # - There is a user track
        unlocked = !!(
          user_track && (
            solutions_data[exercise.slug] ||
            (prerequisites - learnt_concepts).empty?
          )
        )

        if solution_data
          status = solution_data[:status]
        elsif unlocked
          status = :available
        else
          status = :locked
        end

        exercise_data = {
          slug: exercise.slug,
          type: exercise.git_type.to_sym,
          prerequisites: prerequisites,
          status: status,
          unlocked: unlocked,
          has_solution: !!solution_data,
          completed: solution_data&.fetch(:completed)
        }
        exercise_data[:taught_concepts] = exercise.taught_concepts.map(&:slug) if exercise.concept_exercise?
        data[exercise.slug] = exercise_data
      end
    end

    memoize
    def solutions_data
      return {} unless user_track

      solutions = user_track.solutions.includes(:exercise)
      solutions.each_with_object({}) do |solution, data|
        data[solution.exercise.slug] = {
          slug: solution.exercise.slug,
          status: solution.status,
          completed: solution.completed?
        }
      end
    end

    memoize
    def concept_exercises_data
      exercises_data.select { |_, ex| ex[:type] == :concept }
    end

    memoize
    def practice_exercises_data
      exercises_data.select { |_, ex| ex[:type] == :practice }
    end

    memoize
    def learnt_concepts
      return [] unless user_track

      user_track.learnt_concepts.map(&:slug)
    end

    memoize
    def unlocked_concepts
      concept_ids = Exercise::TaughtConcept.
        joins(:exercise).
        where('exercises.slug': unlocked_exercises).
        select(:track_concept_id)

      track.concepts.not_taught.pluck(:slug) + Track::Concept.where(id: concept_ids).pluck(:slug)
    end

    memoize
    def unlocked_exercises
      exercises_data.select { |_, exercise| exercise[:unlocked] }.keys
    end

    ConceptSummary = Struct.new(
      :id, :slug,
      :num_concept_exercises, :num_practice_exercises,
      :num_completed_concept_exercises, :num_completed_practice_exercises,
      :unlocked,
      keyword_init: true
    ) do
      def num_exercises
        num_concept_exercises + num_practice_exercises
      end

      def num_completed_exercises
        num_completed_concept_exercises + num_completed_practice_exercises
      end

      def unlocked?
        unlocked
      end

      def learnt?
        num_concept_exercises.positive? && num_concept_exercises == num_completed_concept_exercises
      end

      def mastered?
        num_exercises.positive? && num_exercises == num_completed_exercises
      end
    end

    ExerciseSummary = Struct.new(
      :id, :slug, :type, :status,
      :unlocked, :has_solution, :completed,
      keyword_init: true
    )
  end
end
