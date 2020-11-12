class UserTrack
  class Summary
    extend Mandate::Memoize

    def initialize(concepts, exercises)
      @mapped_concepts = concepts
      @mapped_exercises = exercises
    end

    def exercise(obj)
      slug = obj.is_a?(Exercise) ? obj.slug : obj.to_s
      mapped_exercises[slug]
    end

    def concept(obj)
      slug = obj.is_a?(Track::Concept) ? obj.slug : obj.to_s
      mapped_concepts[slug]
    end

    def exercise_available?(obj)
      exercise(obj).available
    end

    def exercise_completed?(obj)
      exercise(obj).completed
    end

    def concept_available?(obj)
      concept(obj).available
    end

    def available_exercise_ids
      mapped_exercises.values.select(&:available).map(&:id)
    end

    def available_concept_ids
      mapped_concepts.values.select(&:available).map(&:id)
    end

    memoize
    def num_concepts_mastered
      mapped_concepts.values.count(&:mastered?)
    end

    private
    attr_accessor :track, :user_track, :mapped_concepts, :mapped_exercises
  end
end
