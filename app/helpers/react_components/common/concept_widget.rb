module ReactComponents
  module Common
    class ConceptWidget < ReactComponent
      initialize_with :concept

      def to_s
        super("common-concept-widget", {
          concept: {
            name: concept.name,
            slug: concept.slug,
            links: {
              self: Exercism::Routes.track_concept_path(concept.track, concept),
              tooltip: Exercism::Routes.tooltip_track_concept_path(concept.track, concept)
            }
          }
        })
      end
    end
  end
end
