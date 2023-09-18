module ReactComponents
  module Student
    class PublishSolutionButton < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-publish-solution-button",
          {
            endpoint: Exercism::Routes.publish_api_solution_url(solution.uuid),
            iterations: SerializeIterations.(solution.iterations.order(idx: :desc))
          }
        )
      end
    end
  end
end
