module ViewComponents
  module Track
    class ExerciseHeader < ViewComponent
      initialize_with :exercise, :solution, :user_track, :selected_tab

      def to_s
        tag.header class: "c-exercise-header" do
          render("tracks/exercise_header",
            track:,
            user_track:,
            exercise:,
            solution:,
            selected_tab:) + tabs
        end
      end

      private
      def tabs
        tag.div(class: "lg-container navbar") do
          tag.div(class: "tabs", data: { scrollable_container: 'true' }) do
            safe_join(
              [
                link_to(
                  graphical_icon('overview') +
                  tag.span("Overview", "data-text": "Overview"),
                  Exercism::Routes.track_exercise_path(track, exercise),
                  class: tab_class(:overview),
                  data: tab_scroll_into_view(:overview)
                ),

                (iterations_tab if show_iterations_tab?),
                (dig_deeper_tab if show_dig_deeper_tab?),
                (community_solutions_tab if show_community_solutions_tab?),
                (mentoring_tab if show_mentoring_tab?)
              ]
            )
          end + editor_btn
        end
      end

      def editor_btn
        return nil if user_track.external?

        render ::ReactComponents::Student::OpenEditorButton.new(exercise, user_track)
      end

      def iterations_tab
        parts = []
        parts << graphical_icon('iteration')
        parts << tag.span("Your iterations", "data-text": "Your iterations")
        parts << tag.span(solution.iterations.size, class: "count") if solution&.iterations.present?

        link_to(
          safe_join(parts),
          Exercism::Routes.track_exercise_iterations_path(track, exercise),
          class: tab_class(:iterations),
          data: tab_scroll_into_view(:iterations)
        )
      end

      def dig_deeper_tab
        parts = [
          graphical_icon('dig-deeper'),
          tag.span("Dig Deeper", "data-text": "Dig Deeper")
        ]
        lockable_tab(
          safe_join(parts),
          Exercism::Routes.track_exercise_dig_deeper_path(track, exercise),
          :dig_deeper,
          dig_deeper_tab_locked?,
          locked_tab_tooltip_attrs(Exercism::Routes.tooltip_locked_track_exercise_dig_deeper_path(track, exercise),
            render_react_components: true)
        )
      end

      def community_solutions_tab
        parts = [
          graphical_icon('community-solutions'),
          tag.span("Community Solutions", "data-text": "Community Solutions")
        ]
        lockable_tab(
          safe_join(parts),
          Exercism::Routes.track_exercise_solutions_path(track, exercise),
          :community_solutions,
          solutions_tab_locked?,
          locked_tab_tooltip_attrs(Exercism::Routes.tooltip_locked_track_exercise_solutions_path(track, exercise),
            render_react_components: true)
        )
      end

      def mentoring_tab
        parts = []
        parts << graphical_icon('mentoring')
        parts << tag.span("Code Review", "data-text": "Mentoring")

        if solution
          count = solution.mentor_discussions.count + solution.mentor_requests.pending.count
          parts << tag.span(count, class: "count") if count.positive?
        end

        lockable_tab(
          safe_join(parts),
          Exercism::Routes.track_exercise_mentor_discussions_path(track, exercise),
          :mentoring,
          mentoring_tab_locked?,
          locked_tab_tooltip_attrs(Exercism::Routes.tooltip_locked_track_exercise_mentor_discussions_path(track, exercise))
        )
      end

      def show_iterations_tab? = !user_track.external?
      def show_dig_deeper_tab? = !exercise.tutorial? && exercise.has_approaches?
      def show_community_solutions_tab? = !exercise.tutorial?
      def show_mentoring_tab? = !user_track.external? && !exercise.tutorial?

      def lockable_tab(html, href, class_name, locked, locked_attrs = {})
        css_class = tab_class(class_name, locked:)

        locked ? tag.div(html, class: css_class, 'aria-label': 'This tab is locked', **locked_attrs) :
          link_to(html, href, class: css_class, data: tab_scroll_into_view(class_name))
      end

      def locked_tab_tooltip_attrs(endpoint, render_react_components: false)
        {
          'data-tooltip-type': 'automation-locked',
          'data-endpoint': endpoint,
          'data-placement': 'bottom',
          'data-interactive': true,
          'data-render-react-components': render_react_components
        }
      end

      def tab_class(tab, locked: false)
        "c-tab #{'selected' if tab == selected_tab} #{'locked' if locked}"
      end

      def tab_scroll_into_view(tab)
        { scroll_into_view: ScrollAxis::X } if tab == selected_tab
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end

      memoize
      def track = user_track.track

      memoize
      def user = user_track.user

      def dig_deeper_tab_locked? = !user_track.external? && !solution&.unlocked_help? && !solution&.iterated?
      def solutions_tab_locked? = !user_track.external? && !solution&.unlocked_help? && !solution&.iterated?
      def mentoring_tab_locked? = !user_track.external? && !solution&.iterated?
    end
  end
end
