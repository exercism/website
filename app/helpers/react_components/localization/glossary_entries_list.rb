module ReactComponents
  module Localization
    class GlossaryEntriesList < ReactComponent
      initialize_with :glossary_entries, :params

      def to_s
        super(
          "localization-glossary-entries-list",
          {
            glossary_entries:,
            links: {
              localization_glossary_entries_path: Exercism::Routes.localization_glossary_entries_path,
              endpoint: Exercism::Routes.api_localization_glossary_entries_path
            },
            request: glossary_entries_list_request
          }
        )
      end

      private
      def glossary_entries_list_request
        {
          endpoint: Exercism::Routes.api_localization_glossary_entries_path,
          query: glossary_entries_list_params,
          options: {
            initial_data: glossary_entries_list
          }
        }
      end

      memoize
      def glossary_entries_list_params
        {
          criteria: params.fetch(:criteria, ''),
          status: params[:status],
          page: params[:page]
        }.compact
      end

      def glossary_entries_list = AssembleLocalizationGlossaryEntries.(current_user, params)
    end
  end
end
