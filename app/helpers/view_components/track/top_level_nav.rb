module ViewComponents
  module Track
    class TopLevelNav < ViewComponent
      TABS = %i[overview concepts exercises].freeze

      initialize_with :track, :selected_tab

      def to_s
        guard!

        tag.nav(class: "c-track-top-level-nav") do
          tag.div(class: 'lg-container container') do
            lhs + rhs
          end
        end
      end

      private
      def lhs
        tag.nav(class: "lhs") do
          tag.div(class: "title") do
            track_icon(track) + tag.span(track.title)
          end +
            tag.div(safe_join(tabs), class: 'tabs')
        end
      end

      def rhs
        people
      end

      def people
        tag.div(class: "people") do
          tag.div(class: "c-faces") do
            safe_join(
              track.top_10_contributors[0, 3].map do |author|
                tag.div(avatar(author), class: 'face')
              end
            )
          end +
            tag.div(class: "stats") do
              tag.div(pluralize(track.num_code_contributors, "contributors"), class: 'contributors') +
                tag.div(pluralize(track.num_mentors, "mentors"), class: 'mentors')
            end
        end
      end

      def join_button
        return if current_user&.joined_track?(track)

        url = Exercism::Routes.join_track_path(track)
        view_context.button_to(url, method: :post, class: "btn-small-cta") do
          graphical_icon(:plus) + "Join #{@track.title}"
        end
      end

      def tabs
        [
          link_to(
            graphical_icon(:overview) + tag.span("Overview"),
            Exercism::Routes.track_path(track),
            class: tab_class(:overview)
          ),

          link_to(
            graphical_icon(:concepts) + tag.span("Concepts"),
            Exercism::Routes.track_concepts_path(track),
            class: tab_class(:concepts)
          ),

          link_to(
            graphical_icon(:exercises) + tag.span("Exercises"),
            Exercism::Routes.track_exercises_path(track),
            class: tab_class(:exercises)
          )
        ]
      end

      def tab_class(tab)
        "tab #{'selected' if tab == selected_tab}"
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end
    end
  end
end
