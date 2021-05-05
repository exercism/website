class UserTrack
  class GenerateSummaryData
    include Mandate

    initialize_with :track, :user_track

    def call
      t = Time.now.to_f
      Rails.logger.info "[BM] Starting generating user summary"

      generate_exercises_data!
      calculate_unlocking!
      generate_concepts_data!

      d = {
        concepts: concepts_hash,
        exercises: exercises_hash
      }.with_indifferent_access

      Rails.logger.info "[BM] Finished generating user summary"
      Rails.logger.info "[BM] Generating User Summary: #{Time.now.to_f - t}"

      d
    end

    attr_reader :exercises_data, :concepts_hash

    memoize
    def generate_concepts_data!
      @concepts_hash = track.concepts.each.with_object({}) do |concept, hash|
        concept_exercises = concept_exercises_data.values.
          select { |e| e[:taught_concepts].include?(concept.slug) }.
          map { |e| e[:slug] }

        practice_exercises = practice_exercises_data.values.
          select { |e| e[:practiced_concepts].include?(concept.slug) }.
          map { |e| e[:slug] }

        completed_solutions = solutions_data.values.select { |s| s[:completed] }
        num_completed_concept_solutions = completed_solutions.count { |s| concept_exercises.include?(s[:slug]) }
        num_completed_practice_solutions = completed_solutions.count { |s| practice_exercises.include?(s[:slug]) }

        hash[concept.slug] = {
          id: concept.id,
          slug: concept.slug,
          num_concept_exercises: concept_exercises.count,
          num_practice_exercises: practice_exercises.count,
          num_completed_concept_exercises: num_completed_concept_solutions,
          num_completed_practice_exercises: num_completed_practice_solutions,
          unlocked: unlocked_concepts.include?(concept.slug),
          learnt: learnt_concepts.include?(concept.slug)
        }
      end
    end

    memoize
    def exercises_hash
      exercises_data.transform_values do |exercise|
        exercise.slice(:id, :slug, :status, :unlocked, :has_solution, :completed)
      end
    end

    private
    def generate_exercises_data!
      @exercises_data = exercises.each_with_object({}) do |exercise, data|
        prerequisite_concepts = exercise.prerequisites.pluck(:slug)
        practiced_concepts = exercise.practice_exercise? ? exercise.practiced_concepts.pluck(:slug) : []

        solution_data = solutions_data[exercise.slug]

        exercise_data = {
          id: exercise.id,
          slug: exercise.slug,
          type: exercise.git_type.to_sym,
          tutorial: exercise.tutorial?,
          prerequisite_concepts: prerequisite_concepts,
          practiced_concepts: practiced_concepts,
          has_solution: !!solution_data,
          completed: solution_data&.fetch(:completed) || false
        }
        exercise_data[:taught_concepts] = exercise.taught_concepts.pluck(:slug) if exercise.concept_exercise?
        data[exercise.slug] = exercise_data
      end
    end

    def calculate_unlocking!
      tutorial_pending = solutions_data.none? { |_, s| s[:completed] }

      @exercises_data.each do |slug, exercise_data|
        # Exercises are unlocked if:
        # - They've started
        # - There are no outstanding prereqs
        # - There is a user track
        unlocked = exercise_is_unlocked?(exercise_data, tutorial_pending)
        solution_data = solutions_data[slug]

        if solution_data
          status = solution_data[:status]
        else
          status = unlocked ? :available : :locked
        end

        exercise_data[:status] = status
        exercise_data[:unlocked] = unlocked
      end
    end

    def exercise_is_unlocked?(exercise_data, tutorial_pending)
      return true unless user_track
      return true if solutions_data[exercise_data[:slug]]
      return exercise_data[:tutorial] if tutorial_pending

      (exercise_data[:prerequisite_concepts] - learnt_concepts).empty?
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
    def exercises
      (
        track.concept_exercises.includes(:taught_concepts, :prerequisites).to_a +
        track.practice_exercises.includes(:practiced_concepts, :prerequisites).to_a
      ).freeze
    end

    memoize
    def learnt_concepts
      return [] unless user_track

      completed_solution_slugs = solutions_data.select { |_, s| s[:completed] }.keys
      exercises_data.select { |slug, _| completed_solution_slugs.include?(slug) }.
        flat_map { |_, exercise_data| exercise_data[:taught_concepts] }
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
  end
end
