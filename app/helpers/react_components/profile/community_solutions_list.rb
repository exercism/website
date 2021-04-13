module ReactComponents
  module Profile
    class CommunitySolutionsList < ReactComponent
      initialize_with :user, :solutions

      def to_s
        super("profile-community-solutions-list", {
          request: request,
          context: :profile
        })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_profile_solutions_url(user),
          options: { initial_data: data }
        }
      end

      def data
        SerializePaginatedCollection.(
          @solutions,
          serializer: SerializeCommunitySolutions,
          meta: {
            unscoped_total: @user.solutions.published.count
          }
        )
      end
    end
  end
end
