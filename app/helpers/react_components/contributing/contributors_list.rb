module ReactComponents
  module Contributing
    class ContributorsList < ReactComponent
      extend Mandate::Memoize

      def initialize(params)
        super()

        @params = params
      end

      def to_s
        super(
          "contributing-contributors-list",
          {
            request: {
              endpoint: Exercism::Routes.api_contributors_url,
              options: {
                initial_data: initial_data
              }
            },
            tracks: [
              {
                id: nil,
                title: "All",
                icon_url: "ICON"
              }
            ].concat(tracks.map { |track| data_for_track(track) })
          }
        )
      end

      private
      def initial_data
        users = User::ReputationPeriod::Search.()
        contextual_data = User::ReputationToken::CalculateContextualData.(users.map(&:id))
        SerializePaginatedCollection.(
          users,
          serializer: SerializeContributors,
          serializer_kwargs: {
            starting_rank: 1,
            contextual_data: contextual_data
          }
        )
      end

      def data_for_track(track)
        {
          id: track.slug,
          title: track.title,
          icon_url: track.icon_url
        }
      end

      def tracks
        ::Track.all
      end
    end
  end
end
