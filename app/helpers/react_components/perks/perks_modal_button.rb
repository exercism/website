module ReactComponents
  module Perks
    class PerksModalButton < ReactComponent
      initialize_with :perk

      def to_s
        super(
          "perks-modal-button",
          {
            text: perk.button_text_for_user(current_user),
            perk: {
              offer_summary_html: perk.offer_summary_html_for_user(current_user),
              offer_details: perk.offer_details_for_user(current_user),
              voucher_code: perk.voucher_code_for_user(current_user),
              claim_url: Exercism::Routes.claim_perk_path(perk)
            },
            partner: {
              website_domain: partner.website_domain
            }
          }
        )
      end

      delegate :partner, to: :perk
    end
  end
end
