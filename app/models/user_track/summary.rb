class UserTrack
  class Summary
    extend Mandate::Memoize

    def initialize(data)
      @mapped_concepts = data['concepts'].transform_values { |v| ConceptSummary.new(v) }
      @mapped_exercises = data['exercises'].transform_values { |v| ExerciseSummary.new(v) }
    end

    #########################
    # Active Record methods #
    #########################

    memoize
    def unlocked_concept_exercises
      unlocked_exercises.select { |e| e.is_a?(ConceptExercise) }
    end

    memoize
    def unlocked_practice_exercises
      unlocked_exercises.select { |e| e.is_a?(PracticeExercise) }
    end

    memoize
    def learnt_concepts
      Track::Concept.where(id: learnt_concept_ids)
    end

    memoize
    def unlocked_concepts
      Track::Concept.where(id: unlocked_concept_ids)
    end

    memoize
    def mastered_concepts
      Track::Concept.where(id: mastered_concept_ids)
    end

    memoize
    def unlocked_exercises
      Exercise.where(id: unlocked_exercise_ids)
    end

    def sample_available_exercises(size)
      Exercise.where(id: available_exercise_ids.sample(size))
    end

    def sample_in_progress_exercises(size)
      Exercise.where(id: in_progress_exercise_ids.sample(size))
    end

    def sample_completed_exercises(size)
      Exercise.where(id: completed_exercises_ids.sample(size))
    end

    memoize
    def available_exercises
      Exercise.where(id: available_exercise_ids)
    end

    memoize
    def in_progress_exercises
      Exercise.where(id: in_progress_exercise_ids)
    end

    memoize
    def completed_exercises
      Exercise.where(id: completed_exercises_ids)
    end

    ####################
    # Exercise methods #
    ####################
    def exercise_unlocked?(obj)
      exercise(obj).unlocked
    end

    def exercise_completed?(obj)
      exercise(obj).completed
    end

    def exercise_status(obj)
      exercise(obj).status
    end

    def exercise_type(obj)
      exercise(obj).type
    end

    ###############################
    # Exercises aggregate methods #
    ###############################
    def num_exercises
      mapped_exercises.count
    end

    def num_completed_exercises
      mapped_exercises.values.count(&:completed)
    end

    def num_completed_concept_exercises
      mapped_exercises.values.select { |e| e.type == "concept" }.count(&:completed)
    end

    def num_completed_practice_exercises
      mapped_exercises.values.select { |e| e.type == "practice" }.count(&:completed)
    end

    def num_available_exercises
      available_exercise_ids.size
    end

    def num_locked_exercises
      num_exercises - unlocked_exercise_ids.size
    end

    def num_in_progress_exercises
      in_progress_exercise_ids.size
    end

    def unlocked_exercise_ids
      mapped_exercises.values.select(&:unlocked).map(&:id)
    end

    def available_exercise_ids
      mapped_exercises.values.select(&:unlocked).reject(&:has_solution).map(&:id)
    end

    def in_progress_exercise_ids
      mapped_exercises.values.select(&:has_solution).reject(&:completed).map(&:id)
    end

    def completed_exercises_ids
      mapped_exercises.values.select(&:completed).map(&:id)
    end

    ###################
    # Concept methods #
    ###################
    def concept_unlocked?(obj)
      concept(obj).unlocked?
    end

    def concept_learnt?(obj)
      concept(obj).learnt?
    end

    def concept_mastered?(obj)
      concept(obj).mastered?
    end

    def num_exercises_for_concept(concept)
      concept(concept).num_exercises
    end

    def num_completed_exercises_for_concept(concept)
      concept(concept).num_completed_exercises
    end

    #############################
    # Concept aggregate methods #
    #############################
    memoize
    def concept_slugs
      mapped_concepts.values.map(&:slug)
    end

    memoize
    def unlocked_concept_ids
      mapped_concepts.values.select(&:unlocked?).map(&:id)
    end

    memoize
    def unlocked_concept_slugs
      mapped_concepts.values.select(&:unlocked?).map(&:slug)
    end

    memoize
    def learnt_concept_ids
      mapped_concepts.values.select(&:learnt?).map(&:id)
    end

    memoize
    def learnt_concept_slugs
      mapped_concepts.values.select(&:learnt?).map(&:slug)
    end

    memoize
    def mastered_concept_ids
      mapped_concepts.values.select(&:mastered?).map(&:id)
    end

    memoize
    def mastered_concept_slugs
      mapped_concepts.values.select(&:mastered?).map(&:slug)
    end

    memoize
    def num_concepts
      mapped_concepts.size
    end

    # TODO: Add test coverage
    memoize
    def num_concepts_learnt
      mapped_concepts.values.count(&:learnt?)
    end

    # TODO: Add test coverage
    memoize
    def num_concepts_mastered
      mapped_concepts.values.count(&:mastered?)
    end

    memoize
    def concept_progressions
      mapped_concepts.each.with_object({}) do |(_, concept), h|
        h[concept.id] = {
          completed: concept.num_completed_exercises,
          total: concept.num_exercises
        }
      end
    end

    #################
    # Private stuff #
    #################

    def exercise(obj)
      slug = obj.is_a?(Exercise) ? obj.slug : obj.to_s
      mapped_exercises[slug]
    end

    def concept(obj)
      slug = obj.is_a?(Track::Concept) ? obj.slug : obj.to_s
      mapped_concepts[slug]
    end

    private
    attr_accessor :track, :user_track, :mapped_concepts, :mapped_exercises

    ConceptSummary = Struct.new(
      :id, :slug,
      :num_concept_exercises, :num_practice_exercises,
      :num_completed_concept_exercises, :num_completed_practice_exercises,
      :unlocked, :learnt,
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
