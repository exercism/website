module ReactComponents
  module Student
    class UpdateExerciseNotice < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-update-exercise-notice",
          {
            # The student's version has no translation, so they are reading the latest one's
            docs_for_newer_version: solution.docs_for_newer_version?,
            links: {
              diff: Exercism::Routes.diff_api_solution_url(solution.uuid),
              english: Exercism::Routes.track_exercise_url(solution.track, solution.exercise, locale: nil)
            }
          }
        )
      end

      private
      attr_reader :solution
    end
  end
end
