module ViewComponents
  module Track
    class TopLevelNav < ViewComponent
      TABS = %i[overview concepts exercises].freeze

      initialize_with :track, :selected_tab

      def to_s
        guard!

        GenericNav.new(
          track,
          "c-track-top-level-nav",
          [tag.div(safe_join(tabs), class: 'tabs')]
        ).to_s
      end

      private
      def tabs
        [
          link_to(
            Exercism::Routes.track_path(track),
            class: tab_class(:overview)
          ) do
            icon(:dashboard, "Track Overview") + "Overview"
          end,

          link_to(
            Exercism::Routes.track_concepts_path(track),
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
