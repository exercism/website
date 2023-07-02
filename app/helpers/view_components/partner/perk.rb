module ViewComponents
  class Partner::Perk < ViewComponent
    include Mandate

    initialize_with :perk, preview: false

    def to_s
      render(
        template: "components/perk",
        locals: {
          perk:,
          button_tag: preview ? :div : :a
        }
      )
    end
  end
end
