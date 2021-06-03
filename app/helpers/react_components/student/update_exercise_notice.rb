module ReactComponents
  module Student
    class UpdateExerciseNotice < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-update-exercise-notice",
          {
            links: {
              diff: Exercism::Routes.diff_api_solution_url(solution.uuid)
            }
          }
        )
      end

      private
      attr_reader :solution
    end
  end
end
