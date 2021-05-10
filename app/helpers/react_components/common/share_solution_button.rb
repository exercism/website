module ReactComponents
  module Common
    class ShareSolutionButton < ReactComponent
      initialize_with :solution

      def to_s
        super("common-share-solution-button", {
          title: "Share #{solution.user.handle}'s solution",
          links: {
            solution: Exercism::Routes.published_solution_url(solution)
          }
        })
      end
    end
  end
end
