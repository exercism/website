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
              endpoint: Exercism::Routes.api_localization_glossary_entries_path,
              create_glossary_entry: Exercism::Routes.api_localization_glossary_entries_path
            },
            request: glossary_entries_list_request,
            translation_locales: current_user.data.translator_locales,
            # Can't visit `show` from unchecked status, can't create a new proposal
            may_create_translation_proposals: current_user.may_create_translation_proposals?,
            # Can't visit `show` from proposed status
            may_manage_translation_proposals: current_user.may_manage_translation_proposals?
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

      def glossary_entries_list
        AssembleLocalizationGlossaryEntries.(current_user, glossary_entries_list_params)
      end
    end
  end
end
