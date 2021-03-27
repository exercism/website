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

    #######################
    # Non-summary methods #
    #######################
    def external?
      true
    end

    def learnt_concepts
      []
    end

    ####################
    # Exercise methods #
    ####################
    def exercise_unlocked?(_)
      false
    end

    def exercise_completed?(_)
      false
    end

    ###############################
    # Exercises aggregate methods #
    ###############################
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
      obj.is_a?(Track::Concept) ? slug = obj.slug : slug = obj.to_s
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

    memoize
    def num_concepts
      track.concepts.size
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
  end
end
