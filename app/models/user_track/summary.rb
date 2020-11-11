class UserTrack
  class Summary
    def initialize(user_track)
      @user_track = user_track
      populate!
    end

    def concept(slug)
      concepts[slug]
    end

    private
    attr_accessor :user_track, :concepts

    def populate!
      data = UserTrack::GenerateSummary.(user_track)
      @concepts = data[:concepts]
    end

    ConceptSummary = Struct.new(
      :slug,
      :num_concept_exercises, :num_practice_exercises,
      :num_completed_concept_exercises, :num_completed_practice_exercises,
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
  end
end
