module ReactComponents
  module Track
    class ConceptMakersButton < ReactComponent
      initialize_with :concept

      def to_s
        return if num_authors.zero? && num_contributors.zero?

        super("track-concept-makers-button", {
          avatar_urls:,
          num_authors:,
          num_contributors:,
          links: {
            makers: Exercism::Routes.api_track_concept_makers_url(concept.track, concept)
          }
        })
      end

      def avatar_urls
        target = 3
        urls = Set.new
        urls += concept.authors.order("RAND()").limit(3).select(:id, :version).to_a.map(&:avatar_url)
        if urls.size < 3 && num_contributors.positive?
          urls += concept.contributors.order("RAND()").limit(target - urls.size).select(:id, :version).to_a.map(&:avatar_url)
        end
        urls.compact
      end

      memoize
      def num_authors
        concept.authors.count
      end

      memoize
      def num_contributors
        concept.contributors.count
      end
    end
  end
end
