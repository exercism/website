module ViewComponents
  module CommunitySolutions
    class ShareSolutionButton < ViewComponent
      initialize_with :solution

      def to_s
        ReactComponents::Common::ShareButton.new(
          {
            title: "Share #{solution.user.handle}'s solution",
            share_title: "View this solution on Exercism",
            share_link: Exercism::Routes.published_solution_url(solution)
          }
        ).to_s
      end
    end
  end
end
