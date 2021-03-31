module ViewComponents
  module Track
    class ExerciseHeader < ViewComponent
      initialize_with :track, :exercise, :solution, :selected_tab

      def to_s
        tag.header class: "c-exercise-header" do
          render("tracks/exercise_header",
            track: track,
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

                link_to(
                  graphical_icon('community-solutions') +
                  tag.span("Community Solutions", "data-text": "Community Solutions"),
                  Exercism::Routes.track_exercise_community_solutions_path(track, exercise),
                  class: tab_class(:community_solutions)
                )
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

      def tab_class(tab)
        "c-tab #{'selected' if tab == selected_tab}"
      end

      def guard!
        raise "Incorrect track nav tab" unless TABS.include?(selected_tab)
      end
    end
  end
end
