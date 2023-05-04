module ReactComponents
  module Student
    class CompleteExerciseButton < ReactComponent
      initialize_with :user, :exercise

      def to_s
        super(
          "student-complete-exercise-button",
          {
            endpoint: Exercism::Routes.complete_api_solution_url(solution.uuid),
            iterations: SerializeIterations.(solution.iterations.order(idx: :desc))
          }
        )
      end

      private
      def solution
        Solution.for(user, exercise)
      end
    end
  end
end
