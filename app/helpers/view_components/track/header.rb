module ViewComponents
  module Track
    class Header < ViewComponent
      TABS = %i[overview concepts exercises].freeze

      initialize_with :track, :selected_tab

      # TODO: (Optional) Cache this:
      # [track.id, selected_tab, track.updated_at, Date.today]
      def to_s
        guard!

        tag.header class: "c-track-header" do
          render(
            "tracks/header",
            track: track,
            user_track: user_track,
            tabs: tabs,
            tags: tags
          )
        end
      end

      def tags
        ts = []
        if user_track&.practice_mode?
          ts << tag.div(class: 'c-tag --practice-mode --compact') do
            graphical_icon("practice-mode") +
              tag.span("Practice Mode")
          end
        end

        safe_join(ts)
      end

      def tabs
        tabs = []
        tabs << link_to(
          graphical_icon(:overview) + tag.span("Overview"),
          Exercism::Routes.track_path(track),
          class: tab_class(:overview)
        )

        unless user_track.practice_mode?
          tabs << link_to(
            graphical_icon(:concepts) + tag.span("Syllabus"),
            Exercism::Routes.track_concepts_path(track),
            class: tab_class(:concepts)
          )
        end

        tabs << link_to(
          graphical_icon(:exercises) + tag.span("Exercises"),
          Exercism::Routes.track_exercises_path(track),
          class: tab_class(:exercises)
        )

        safe_join(tabs)
      end

      def tab_class(tab)
        "c-tab-2 #{'selected' if tab == selected_tab}"
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end

      memoize
      def user_track
        UserTrack.for(current_user, track)
      end
    end
  end
end
