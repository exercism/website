module ReactComponents
  module Localization
    class OriginalsShow < ReactComponent
      initialize_with :original

      def to_s
        super("localization-originals-show", {
          original:,
          current_user_id: current_user&.id,
          links: {
            originals_list_page: Exercism::Routes.localization_originals_url,
            approve_llm_translation: Exercism::Routes.approve_llm_version_api_localization_translation_url(original[:uuid]),
            create_proposal: Exercism::Routes.api_localization_translation_proposals_url(translation_id: "TRANSLATION_ID"),
            approve_proposal: Exercism::Routes.approve_api_localization_translation_proposal_url(translation_id: "TRANSLATION_ID", id: "PROPOSAL_ID"), # rubocop:disable Layout/LineLength
            reject_proposal: Exercism::Routes.reject_api_localization_translation_proposal_url(translation_id: "TRANSLATION_ID", id: "PROPOSAL_ID"), # rubocop:disable Layout/LineLength
            update_proposal: Exercism::Routes.api_localization_translation_proposal_url(translation_id: "TRANSLATION_ID", id: "PROPOSAL_ID") # rubocop:disable Layout/LineLength
          }
        })
      end
    end
  end
end
