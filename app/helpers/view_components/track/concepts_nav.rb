module ViewComponents
  module Track
    class ConceptsNav < ViewComponent
      initialize_with :track

      def to_s
        GenericNav.new(
          track,
          "c-track-concepts-nav",
          [
            tag.div(">", class: 'divider'),
            link_to("Concepts", Exercism::Routes.track_concepts_path(track))
          ]
        ).to_s
      end

      private
      def tabs
        [
          link_to(
            Exercism::Routes.track_path(@track),
            class: tab_class(:overview)
          ) do
            icon(:dashboard, "Track Overview") + "Overview"
          end,

          link_to(
            Exercism::Routes.track_concepts_path(@track),
            class: tab_class(:concepts)
          ) do
            icon(:concepts, "Concepts") + "Concepts"
          end,

          link_to("#", class: tab_class(:exercises)) do
            icon(:exercises, "Exercises") + "Exercises"
          end
        ]
      end

      def tab_class(tab)
        tab == selected_tab ? "selected" : ""
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end
    end
  end
end
