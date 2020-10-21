module ViewComponents
  module Student
    class TrackNav < ViewComponent
      TABS = %i[overview concepts exercises].freeze

      initialize_with :track, :selected_tab

      def to_s
        guard!

        tag.nav(class: 'c-track-nav') do
          tag.div(class: 'lg-container container') do
            parts = [
              link_to(
                graphical_icon("arrow-left"),
                Exercism::Routes.tracks_path,
                class: "back",
                'aria-label': "Back to all tracks"
              ),
              image_tag(@track.icon_url, class: 'c-track-icon'),
              tag.div(@track.title, class: 'title'),
              tag.div(safe_join(tabs), class: 'tabs')
            ]
            safe_join(parts)
          end
        end
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
