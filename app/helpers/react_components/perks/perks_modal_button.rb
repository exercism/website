module ReactComponents
  module Perks
    class PerksModalButton < ReactComponent
      initialize_with text: nil, perk: nil, claim_perk_path: nil, partner: nil, current_user: nil
      def to_s
        super(
          "perks-modal-button",
          {
            text:,
            perk: {
              offer_summary_html: perk.offer_summary_html_for_user(current_user),
              offer_details: perk.offer_details_for_user(current_user),
              voucher_code: perk.voucher_code_for_user(current_user),
              claim_url: claim_perk_path
            },
            partner: {
              website_domain: partner.website_domain
            }
          }
        )
      end
    end
  end
end
