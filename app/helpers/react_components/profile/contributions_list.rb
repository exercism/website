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
            count: User::ReputationToken::Search.(@user, category: %i[building authoring], paginated: false,
                                                         sorted: false).count,
            endpoint: Exercism::Routes.building_api_profile_contributions_url(user.handle)
          },
          {
            title: "Maintaining",
            icon: "maintaining",
            count: User::ReputationToken::Search.(@user, category: :maintaining, paginated: false, sorted: false).count,
            endpoint: Exercism::Routes.maintaining_api_profile_contributions_url(user.handle)
          },
          {
            title: "Authoring",
            icon: "concepts",
            count: User::RetrieveAuthoredAndContributedExercises.(@user, paginated: false, sorted: false).count,
            endpoint: Exercism::Routes.authoring_api_profile_contributions_url(user.handle)
          }
        ].select { |c| c[:count].positive? }
      end
    end
  end
end
