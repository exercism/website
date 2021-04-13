module ReactComponents
  module Profile
    class CommunitySolutionsList < ReactComponent
      initialize_with :user, :solutions

      def to_s
        super("profile-community-solutions-list", {
          request: request,
          tracks_request: tracks_request
        })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_profile_solutions_url(user),
          query: { order: "newest_first" },
          options: { initial_data: data }
        }
      end

      def tracks_request
        {
          endpoint: Exercism::Routes.api_tracks_url,
          query: { status: "joined" }
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
