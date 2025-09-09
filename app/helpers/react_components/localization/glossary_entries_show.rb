module ReactComponents
  module Localization
    class GlossaryEntriesShow < ReactComponent
      initialize_with :glossary_entry

      def to_s
        super("localization-glossary-entries-show", {
          glossary_entry:,
          current_user_id: current_user&.id,
          links: {
            glossary_entries_list_page: Exercism::Routes.localization_glossary_entries_url,
            approve_llm_translation: Exercism::Routes.approve_llm_version_api_localization_translation_url(glossary_entry[:uuid]),
            create_proposal: Exercism::Routes.api_localization_glossary_entry_proposals_url(glossary_entry_id: "GLOSSARY_ENTRY_ID", id: "ID"), # rubocop:disable Layout/LineLength
            approve_proposal: Exercism::Routes.approve_api_localization_glossary_entry_proposal_url(glossary_entry_id: "GLOSSARY_ENTRY_ID", id: "ID"), # rubocop:disable Layout/LineLength
            reject_proposal: Exercism::Routes.reject_api_localization_glossary_entry_proposal_url(glossary_entry_id: "GLOSSARY_ENTRY_ID", id: "ID"), # rubocop:disable Layout/LineLength
            update_proposal: Exercism::Routes.api_localization_glossary_entry_proposal_url(glossary_entry_id: "GLOSSARY_ENTRY_ID", id: "ID") # rubocop:disable Layout/LineLength
          }
        })
      end
    end
  end
end
