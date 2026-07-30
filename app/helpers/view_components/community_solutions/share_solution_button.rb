module ViewComponents
  module CommunitySolutions
    class ShareSolutionButton < ViewComponent
      initialize_with :solution

      def to_s
        ReactComponents::Common::ShareButton.new(
          {
            title: I18n.t("components.community_solutions.share_solution_button.title", handle: solution.user.handle),
            share_title: I18n.t("components.community_solutions.share_solution_button.share_title"),
            share_link: Exercism::Routes.published_solution_url(solution)
          }
        ).to_s
      end
    end
  end
end
