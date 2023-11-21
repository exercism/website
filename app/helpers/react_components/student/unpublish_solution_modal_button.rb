module ReactComponents
  module Student
    class UnpublishSolutionModalButton < ReactComponent
      initialize_with :solution, :label

      def to_s
        super(
          "student-unpublish-solution-modal-button",
          {
            links: {
              unpublish: Exercism::Routes.unpublish_api_solution_url(solution.uuid)
            },
            label:
          }
        )
      end
    end
  end
end
