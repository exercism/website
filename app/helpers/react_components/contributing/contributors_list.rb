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
          "contributors-list",
          {
            initial_data: initial_data
          }
        )
      end

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
    end
  end
end
