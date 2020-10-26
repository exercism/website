module ViewComponents
  module Track
    class ConceptsNav < ViewComponent
      initialize_with :track

      def to_s
        GenericNav.new(
          track,
          "c-track-concepts-nav",
          [
            tag.div("/", class: 'divider'),
            link_to("Concepts", Exercism::Routes.track_concepts_path(track), class: 'item')
          ]
        ).to_s
      end
    end
  end
end
