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
              query:,
              options: {
                initial_data:
              }
            },
            tracks: AssembleTracksForSelect.()
          }
        )
      end

      private
      attr_reader :params

      memoize
      def initial_data
        AssembleContributors.(params)
      end

      memoize
      def query
        {
          page: current_page,
          period: params[:period],
          track_slug: params[:track_slug],
          category: params[:category]
        }.compact
      end

      memoize
      def current_page
        page = initial_data[:meta][:current_page]

        page != 1 ? page : nil
      end
    end
  end
end
