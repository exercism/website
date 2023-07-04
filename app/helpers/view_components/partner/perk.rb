module ViewComponents
  class Partner::Perk < ViewComponent
    include Mandate

    initialize_with :perk, preview: false

    def to_s
      render(
        template: "components/perk",
        locals: {
          perk:,
          offer_summary_html: perk.offer_summary_html_for_user(current_user),
          button_tag: preview ? :div : :a,
          button_text: perk.button_text_for_user(current_user)
        }
      )
    end
  end
end
