module ViewComponents
  module CommunitySolutions
    class ShareSolutionButton < ViewComponent
      def self.platforms
        ReactComponents::Common::ShareButton.platforms
      end

      def initialize(solution, platforms = self.class.platforms)
        @solution = solution
        @platforms = platforms

        super()
      end

      def to_s
        ReactComponents::Common::ShareButton.new(
          {
            title: "Share #{solution.user.handle}'s solution",
            share_title: "View this solution on Exercism",
            share_link: Exercism::Routes.published_solution_url(solution)
          },
          platforms
        ).to_s
      end

      private
      attr_reader :solution, :platforms
    end
  end
end
