module ReactComponents
  module Student
    class CompleteExerciseButton < ReactComponent
      initialize_with :user, :exercise

      def to_s
        super(
          "student-complete-exercise-button",
          {
            endpoint: Exercism::Routes.complete_api_solution_url(solution.uuid)
          }
        )
      end

      private
      attr_reader :exercise

      def solution
        Solution.for(user, exercise)
      end
    end
  end
end
