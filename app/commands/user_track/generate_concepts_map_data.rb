class UserTrack
  class GenerateConceptsMapData
    include Mandate

    initialize_with :user_track

    def call
      Track::DetermineConceptsLayout.(user_track.track).tap { |data| data[:status] = concepts_status }
    end

    private
    memoize
    def concepts_status
      all_concepts = user_track.track.concepts.map(&:slug)
      available_concepts = user_track.available_concepts.map(&:slug)
      learnt_concepts = user_track.learnt_concepts.map(&:slug)

      {}.
        tap { |h| all_concepts.each { |concept| h[concept] = :locked } }.
        tap { |h| available_concepts.each { |concept| h[concept] = :unlocked } }.
        tap { |h| learnt_concepts.each { |concept| h[concept] = :complete } }
    end
  end
end
