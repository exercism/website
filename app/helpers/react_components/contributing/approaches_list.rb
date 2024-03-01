module ReactComponents
  module Contributing
    class ApproachesList < ReactComponent
      extend Mandate::Memoize

      initialize_with :params

      def to_s
        super(
          "contributing-approaches-list",
          {
            request: {
              endpoint: Exercism::Routes.api_approaches_url,
              query:,
              options: {
                initial_data: AssembleApproaches.(params)
              }
            },
            tracks: AssembleTracksForSelect.()
            # TODO: output only relevant tracks
            # TODO: output exercises
          }
        )
      end

      private
      memoize
      def query
        {
          exercise_slug: params[:exercise_slug] || "",
          track_slug: params[:track_slug] || "",
          order: params[:order] || "newest",
          page: params[:page] || 1
        }
      end
    end
  end
end
