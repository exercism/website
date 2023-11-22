module ViewComponents
  module Track
    class Header < ViewComponent
      TABS = %i[overview concepts exercises about build].freeze

      initialize_with :track, :selected_tab

      # TODO: (Optional) Cache this:
      # [track.id, selected_tab, track.updated_at, Date.today]
      def to_s
        guard!

        tag.header class: "c-track-header" do
          render(
            "tracks/header",
            track:,
            tags:,
            tabs:,
            selected_tab:,
            practice_mode:,
            external:,
            course:
          )
        end
      end

      def tags
        ts = []
        if practice_mode
          ts << tag.div(class: 'c-tag --practice-mode --compact') do
            graphical_icon("practice-mode") +
              tag.span("Practice Mode")
          end
        end

        safe_join(ts)
      end

      def tabs
        tabs = []
        if user_track.external?
          tabs << about_tab(:track_path)
        else
          tabs << link_to(
            graphical_icon(:overview) + tag.span("Overview"),
            Exercism::Routes.track_path(track),
            class: tab_class(:overview),
            data: scroll_into_view(:overview)
          )
        end

        tabs << concepts_tab if course && !practice_mode
        tabs << exercises_tab
        tabs << about_tab(:about_track_path) unless external
        # tabs << build_tab if current_user&.maintainer?

        safe_join(tabs)
      end

      def about_tab(url)
        link_to(
          graphical_icon('info-circle') + tag.span("About #{track.title}"),
          Exercism::Routes.send(url, track),
          class: tab_class(:about),
          data: scroll_into_view(:about)
        )
      end

      def concepts_tab
        link_to(
          graphical_icon(:concepts) + tag.span("Learn"),
          Exercism::Routes.track_concepts_path(track),
          class: tab_class(:concepts),
          data: scroll_into_view(:concepts)
        )
      end

      def exercises_tab
        link_to(
          graphical_icon(:exercises) + tag.span("Practice"),
          Exercism::Routes.track_exercises_path(track),
          class: tab_class(:exercises),
          data: scroll_into_view(:exercises)
        )
      end

      def build_tab
        link_to(
          graphical_icon(:building) + tag.span("Build Status"),
          Exercism::Routes.track_build_path(track),
          class: tab_class(:build),
          data: scroll_into_view(:build)
        )
      end

      def tab_class(tab)
        "c-tab-2 #{'selected' if tab == selected_tab}"
      end

      def scroll_into_view(tab)
        { scroll_into_view: (tab == selected_tab ? ScrollAxis::X : nil) }
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end

      def practice_mode = !!user_track&.practice_mode?
      def external = !!user_track&.external?
      def course = !!user_track&.course?

      memoize
      def user_track = UserTrack.for(current_user, track)
    end
  end
end
