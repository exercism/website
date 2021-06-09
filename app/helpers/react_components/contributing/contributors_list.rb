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
              query: query,
              options: {
                initial_data: initial_data
              }
            }
          }.merge(AssembleTrackSwitcher.())
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
        q = {}
        q[:page] = initial_data[:meta][:current_page]
        q[:period] = params[:period] if params[:period].present?
        q[:track] = params[:track] if params[:track].present?
        q[:category] = params[:category] if params[:category].present?
        q
      end
    end
  end
end
