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
          tag.div(class: "tabs") do
            safe_join(
              [
                link_to(
                  graphical_icon('overview') +
                  tag.span("Overview", "data-text": "Overview"),
                  Exercism::Routes.track_exercise_path(track, exercise),
                  class: tab_class(:overview)
                ),

                (iterations_tab unless user_track.external?),
                (approaches_tab if show_approaches_tab?),
                (community_solutions_tab unless exercise.tutorial?),
                (mentoring_tab unless user_track.external? || exercise.tutorial?)
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
          class: tab_class(:iterations)
        )
      end

      def approaches_tab
        parts = [
          graphical_icon('community-solutions'), # TODO: Aron
          tag.span("Dig Deeper", "data-text": "Dig Deeper")
        ]
        lockable_tab(
          safe_join(parts),
          Exercism::Routes.track_exercise_approaches_path(track, exercise),
          :approaches,
          approaches_tab_locked?
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
          solutions_tab_locked?
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
          :mentoring,
          mentoring_tab_locked?
        )
      end

      def lockable_tab(html, href, class_name, locked)
        css_class = tab_class(class_name, locked:)

        locked ? tag.div(html, class: css_class) :
          link_to(html, href, class: css_class)
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
      def show_approaches_tab?
        false # TODO: @erikschierboom
      end

      memoize
      def approaches_tab_locked?
        solutions_tab_locked?
      end

      memoize
      def solutions_tab_locked?
        return false if user_track.external?

        # TODO: @erikschierboom
        mentoring_tab_locked?
      end

      memoize
      def mentoring_tab_locked?
        !@solution&.iterated?
      end
    end
  end
end
