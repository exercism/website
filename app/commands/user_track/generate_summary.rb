class UserTrack
  class GenerateSummary
    include Mandate

    initialize_with :track, :user_track

    # We want to ensure we only do this once, but we
    # provide two access vectors, this and the
    # user_track.summary. This slightly hacky method
    # checks whether we've already done this work and
    # if so returns what we already have. Otherwise
    # it does the work and then sets it.
    #
    # If we don't have a user_track, then we just generate
    # the data and don't worry about this bit.
    def call
      return generate! unless user_track

      return user_track.summary if user_track.summary_generated?

      user_track.summary = generate!
    end

    def generate!
      t = Time.now.to_f
      Rails.logger.info "[BM] Starting generating user summary"

      UserTrack::Summary.new(
        concepts.map { |k, v| [k, ConceptSummary.new(v)] }.to_h,
        exercises.map { |k, v| [k, ExerciseSummary.new(v)] }.to_h
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
          available: available_concepts.include?(concept.slug)
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
          available: exercise_data[:available],
          started: exercise_data[:started],
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

        # Exercises are available if:
        # - They've started
        # - There are no outstanding prereqs
        # - There is a user track
        available = !!(
          user_track && (
            solutions_data[exercise.slug] ||
            (prerequisites - learnt_concepts).empty?
          )
        )

        # Exercises are started if there is solution
        # in the database for them.
        started = !!solutions_data[exercise.slug]

        completed = started && solutions_data[exercise.slug][:completed]

        exercise_data = {
          slug: exercise.slug,
          type: exercise.git_type.to_sym,
          prerequisites: prerequisites,
          available: available,
          started: started,
          completed: completed
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
    def available_concepts
      concept_ids = Exercise::TaughtConcept.
        joins(:exercise).
        where('exercises.slug': available_exercises).
        select(:track_concept_id)

      track.concepts.not_taught.pluck(:slug) + Track::Concept.where(id: concept_ids).pluck(:slug)
    end

    memoize
    def available_exercises
      exercises_data.select { |_, exercise| exercise[:available] }.keys
    end

    ConceptSummary = Struct.new(
      :id, :slug,
      :num_concept_exercises, :num_practice_exercises,
      :num_completed_concept_exercises, :num_completed_practice_exercises,
      :available,
      keyword_init: true
    ) do
      def num_exercises
        num_concept_exercises + num_practice_exercises
      end

      def num_completed_exercises
        num_completed_concept_exercises + num_completed_practice_exercises
      end

      def mastered?
        num_exercises.positive? && num_exercises == num_completed_exercises
      end
    end

    ExerciseSummary = Struct.new(
      :id, :slug,
      :available, :started, :completed,
      keyword_init: true
    )
  end
end
