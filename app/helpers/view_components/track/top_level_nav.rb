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
            graphical_icon(:dashboard) +
              tag.span("Overview", "data-text": "Overview")
          end,

          link_to(
            Exercism::Routes.track_concepts_path(track),
            class: tab_class(:concepts)
          ) do
            graphical_icon(:concepts) +
              tag.span("Concepts", "data-text": "Concepts")
          end,

          link_to(
            "#",
            class: tab_class(:exercises)
          ) do
            graphical_icon(:exercises) +
              tag.span("Exercises", "data-text": "Exercises")
          end
        ]
      end

      def tab_class(tab)
        "c-tab #{'selected' if tab == selected_tab}"
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end
    end
  end
end
