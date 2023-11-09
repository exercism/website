module ReactComponents
  module Student
    class ChangePublishedIterationModalButton < ReactComponent
      initialize_with :solution, :label

      def to_s
        super(
          "student-change-published-iteration-modal-button",
          {
            published_iteration_idx: solution.published_iteration.try(:idx),
            iterations: SerializeIterations.(solution.iterations.not_deleted.order(idx: :desc)),
            links: {
              change_iteration: Exercism::Routes.published_iteration_api_solution_url(solution.uuid)
            },
            label:
          }
        )
      end
    end
  end
end
