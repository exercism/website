module ReactComponents
  module Perks
    class PerksExternalModalButton < ReactComponent
      initialize_with :perk

      def to_s
        super(
          "perks-external-modal-button",
          {
            text: perk.button_text_for_user(current_user),
            perk: {
              offer_summary_html: perk.offer_summary_html_for_user(current_user),
              offer_details: perk.offer_details_for_user(current_user)
            },
            links: {
              log_in: Exercism::Routes.new_user_session_path,
              sign_up: Exercism::Routes.new_user_registration_path
            }
          }
        )
      end

      delegate :partner, to: :perk
    end
  end
end
