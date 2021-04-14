module ReactComponents
  module Profile
    class ContributionsList < ReactComponent
      initialize_with :user

      def to_s
        super("profile-contributions-list", {
          categories: categories,
          user_handle: user.handle
        })
      end

      private
      def categories
        [
          {
            title: "Building",
            icon: "contribute",
            count: user.reputation_tokens.where(category: %i[building authoring]).count,
            endpoint: Exercism::Routes.building_api_profile_contributions_url(user.handle)
          },
          {
            title: "Maintaining",
            icon: "maintaining",
            count: user.reputation_tokens.where(category: :maintaining).count,
            endpoint: Exercism::Routes.maintaining_api_profile_contributions_url(user.handle)
          },
          {
            title: "Authoring",
            icon: "concepts",
            count: Exercise.where(
              id: user.authored_exercises.select(:id) + user.contributed_exercises.select(:id)
            ).count,
            endpoint: Exercism::Routes.authoring_api_profile_contributions_url(user.handle)
          }
        ].select { |c| c[:count].positive? }
      end
    end
  end
end
