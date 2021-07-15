# This is a version of the user track for when we
# don't have a logged in user but we still want to
# have the functionality of a user track
class UserTrack
  class External
    extend Mandate::Memoize
    attr_reader :track

    def initialize(track)
      @track = track
    end

    delegate :concepts, :num_concepts, :updated_at,
      to: :track

    memoize
    def exercises
      filter_enabled_exercises(track.exercises)
    end

    memoize
    def concept_exercises
      filter_enabled_exercises(track.concept_exercises)
    end

    memoize
    def practice_exercises
      filter_enabled_exercises(track.practice_exercises)
    end

    def concept_exercises_for(concept: nil)
      filter_enabled_exercises(concept.concept_exercises) if concept.present?
    end

    def practice_exercises_for(concept: nil)
      filter_enabled_exercises(concept.practice_exercises) if concept.present?
    end

    #######################
    # Non-summary methods #
    #######################
    def external?
      true
    end

    def practice_mode?
      false
    end

    def last_touched_at
      nil
    end

    memoize
    def concept_slugs
      concepts.map(&:slug)
    end

    def learnt_concepts
      []
    end

    def objectives
      nil
    end

    def exercise_type(obj)
      return obj.git_type if obj.is_a?(Exercise)

      exercise_types[obj]
    end

    memoize
    def exercise_types
      track.exercises.select(:slug, :type).index_by(&:slug).transform_values(&:git_type)
    end

    ####################
    # Exercise methods #
    ####################
    def exercise_unlocked?(_)
      true
    end

    def exercise_completed?(_)
      false
    end

    def exercise_status(_)
      :external
    end

    def exercise_has_notifications?(_)
      false
    end

    ###############################
    # Exercises aggregate methods #
    ###############################

    def num_exercises
      exercises.size
    end

    def num_completed_exercises
      0
    end

    def unlocked_exercise_ids
      []
    end

    ###################
    # Concept methods #
    ###################
    def concept_unlocked?(_)
      false
    end

    def concept_learnt?(_)
      false
    end

    def concept_mastered?(_)
      false
    end

    def num_exercises_for_concept(obj)
      obj.is_a?(Concept) ? slug = obj.slug : slug = obj.to_s
      concept_exercises_counts[slug]
    end

    def num_completed_exercises_for_concept(_)
      0
    end

    #############################
    # Concept aggregate methods #
    #############################
    def unlocked_concept_ids
      []
    end

    def num_concepts_learnt
      0
    end

    def num_concepts_mastered
      0
    end

    ###################
    # Private methods #
    ###################
    private
    memoize
    def concept_exercises_counts
      taught_counts = Exercise::TaughtConcept.
        joins(:exercise, :concept).
        where('exercises.track_id': track.id).
        group('track_concepts.slug').
        count

      practice_counts = Exercise::Prerequisite.
        joins(:exercise, :concept).
        where('exercises.track_id': track.id).
        where('exercises.type': "PracticeExercise").
        group('track_concepts.slug').
        count

      # Sum the counts
      taught_counts.merge(practice_counts) { |_, t, p| t + p }
    end

    def filter_enabled_exercises(exercises)
      exercises.where(status: %i[active beta])
    end
  end
end
