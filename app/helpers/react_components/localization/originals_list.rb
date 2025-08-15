module ReactComponents
  module Localization
    class OriginalsList < ReactComponent
      initialize_with :originals, :params

      def to_s
        super(
          "localization-originals-list",
          {
            originals:,
            links: {
              localization_originals_path: Exercism::Routes.localization_originals_path,
              endpoint: Exercism::Routes.api_localization_originals_path
            },
            request: originals_list_request
          }
        )
      end

      private
      def originals_list_request
        {
          endpoint: Exercism::Routes.api_localization_originals_path,
          query: originals_list_params,
          options: {
            initial_data: originals_list
          }
        }
      end

      memoize
      def originals_list_params
        {
          criteria: params.fetch(:criteria, ''),
          status: params[:status],
          page: params[:page]
        }.compact
      end

      def originals_list = AssembleLocalizationOriginals.(current_user, originals_list_params)
    end
  end
end
