module ViewComponents
  module Track
    class ExerciseNav < ViewComponent
      initialize_with :track, :exercise, :solution, :selected_tab

      def to_s
        GenericNav.new(
          view_context,
          track,
          "c-track-exercise-nav",
          [
            tag.div("/", class: 'divider'),
            link_to("Exercises", Exercism::Routes.track_exercises_path(track), class: 'item'),
            tag.div(safe_join(tabs), class: 'tabs')
          ]
        ).to_s
      end

      private
      def tabs
        [
          link_to(
            tag.span("About exercise", "data-text": "About exercise"),
            Exercism::Routes.track_exercise_path(track, exercise),
            class: tab_class(:about)
          ),

          iterations_tab,

          link_to(
            tag.span("Approaches", "data-text": "Approaches"),
            "#",
            class: tab_class(:approaches)
          )
        ]
      end

      def iterations_tab
        parts = []
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
