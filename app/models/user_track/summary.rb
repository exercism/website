class UserTrack
  class Summary
    extend Mandate::Memoize

    def initialize(concepts, exercises)
      @mapped_concepts = concepts
      @mapped_exercises = exercises
    end

    ####################
    # Exercise methods #
    ####################
    def exercise_available?(obj)
      exercise(obj).available
    end

    def exercise_completed?(obj)
      exercise(obj).completed
    end

    def exercise_status(obj)
      e = exercise(obj)
      return :completed if e.completed
      return :in_progress if e.started
      return :available if e.available

      :locked
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

    def available_exercise_ids
      mapped_exercises.values.select(&:available).map(&:id)
    end

    def in_progress_exercise_ids
      mapped_exercises.values.select(&:started).reject(&:completed).map(&:id)
    end

    def completed_exercises_ids
      mapped_exercises.values.select(&:completed).map(&:id)
    end

    ###################
    # Concept methods #
    ###################
    def concept_available?(obj)
      concept(obj).available?
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
    def available_concept_ids
      mapped_concepts.values.select(&:available).map(&:id)
    end

    def learnt_concept_ids
      mapped_concepts.values.select(&:learnt?).map(&:id)
    end

    def mastered_concept_ids
      mapped_concepts.values.select(&:mastered?).map(&:id)
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
      obj.is_a?(Exercise) ? slug = obj.slug : slug = obj.to_s
      mapped_exercises[slug]
    end

    def concept(obj)
      obj.is_a?(Track::Concept) ? slug = obj.slug : slug = obj.to_s
      mapped_concepts[slug]
    end

    private
    attr_accessor :track, :user_track, :mapped_concepts, :mapped_exercises
  end
end
