class UserTrack
  class GenerateConceptsStatus
    include Mandate

    initialize_with :user_track

    def call
      concepts_status
    end

    private
    memoize
    def concepts_status
      all_concepts = user_track.track.concepts.map(&:slug)
      available_concepts = user_track.available_concepts.map(&:slug)
      learnt_concepts = user_track.learnt_concepts.map(&:slug)

      {}.tap do |output|
        set_status = ->(slugs, status) { slugs.each { |slug| output[slug] = status } }

        set_status.(all_concepts, :locked)
        set_status.(available_concepts, :unlocked)
        set_status.(learnt_concepts, :complete)
      end
    end
  end
end
