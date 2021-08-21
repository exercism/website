module ViewComponents
  module Track
    class ExerciseHeader < ViewComponent
      initialize_with :exercise, :solution, :user_track, :selected_tab

      def to_s
        tag.header class: "c-exercise-header" do
          render("tracks/exercise_header",
            track: track,
            user_track: user_track,
            exercise: exercise,
            solution: solution,
            selected_tab: selected_tab) + tabs
        end
      end

      private
      def tabs
        tag.div(class: "lg-container navbar") do
          tag.div(class: "tabs") do
            safe_join(
              [
                link_to(
                  graphical_icon('overview') +
                  tag.span("Overview", "data-text": "Overview"),
                  Exercism::Routes.track_exercise_path(track, exercise),
                  class: tab_class(:overview)
                ),

                iterations_tab,
                (community_solutions_tab unless exercise.tutorial?),
                (mentoring_tab unless exercise.tutorial?)
              ]
            )
          end + (render ::ReactComponents::Student::OpenEditorButton.new(exercise))
        end
      end

      def iterations_tab
        parts = []
        parts << graphical_icon('iteration')
        parts << tag.span("Your iterations", "data-text": "Your iterations")
        parts << tag.span(solution.iterations.size, class: "count") if solution&.iterations.present?

        link_to(
          safe_join(parts),
          Exercism::Routes.track_exercise_iterations_path(track, exercise),
          class: tab_class(:iterations)
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
          tab_class(:community_solutions, locked: tabs_locked?)
        )
      end

      def mentoring_tab
        parts = []
        parts << graphical_icon('mentoring')
        parts << tag.span("Mentoring", "data-text": "Mentoring")

        if solution
          count = solution.mentor_discussions.count + solution.mentor_requests.pending.count
          parts << tag.span(count, class: "count") if count.positive?
        end

        lockable_tab(
          safe_join(parts),
          Exercism::Routes.track_exercise_mentor_discussions_path(track, exercise),
          tab_class(:mentoring, locked: tabs_locked?)
        )
      end

      def lockable_tab(html, href, css_class)
        if tabs_locked?
          tag.div(html, class: css_class)
        else
          link_to(html, href, class: css_class)
        end
      end

      def tab_class(tab, locked: false)
        "c-tab #{'selected' if tab == selected_tab} #{'locked' if locked}"
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end

      memoize
      def track
        user_track.track
      end

      memoize
      def tabs_locked?
        !@solution&.iterated?
      end
    end
  end
end
