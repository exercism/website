module ViewComponents
  module Student
    class TrackNav < ViewComponent
      TABS = %i[overview concepts exercises].freeze

      initialize_with :track, :selected_tab

      def to_s
        guard!

        tag.nav(class: 'c-track-nav') do
          tag.div(class: 'lg-container container') do
            safe_join([
                        link_to("<-", Exercism::Routes.tracks_path, class: "back", 'aria-label': "Back to all tracks"),
                        image_tag(@track.icon_url, class: 'c-track-icon'),
                        tag.div(@track.title, class: 'title'),
                        tag.div(safe_join(tabs), class: 'tabs')
                      ])
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
            "Overview"
          end,

          link_to(
            Exercism::Routes.track_concepts_path(@track),
            class: tab_class(:concepts)
          ) do
            "Concepts"
          end,

          link_to("#", class: tab_class(:exerises)) do
            "Exercises"
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
