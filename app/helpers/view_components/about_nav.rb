module ViewComponents
  class AboutNav < ViewComponent
    extend Mandate::Memoize

    def initialize(selected_section = nil)
      super()

      @selected_section = selected_section
    end

    def to_s
      tag.div(class: "c-about-nav") do
        tag.div(lhs, class: "lg-container container")
      end
    end

    def lhs
      tag.ul do
        safe_join(
          [
            li_link("About Exercism"),
            li_link("Our Impact", :impact),
            li_link("Team", :team),
            # li_link("Jobs", :hiring),
            li_link("Supporters", :individual_supporters),
            tag.li(link_to("Supporting Orgs", Exercism::Routes.about_supporting_organisations_path),
              class: selected_section == :organisation_supporters ? "selected" : nil)
            # li_link("Community", :community),
            # li_link("Not-for-profit", :organisation),
            # li_link("Track-specific", :tracks)
          ]
        )
      end
    end

    def li_link(title, section = nil)
      css_class = section == selected_section ? "selected" : nil
      scroll_into_view = section == selected_section ? true : nil
      url = Exercism::Routes.send([section, "about_path"].compact.join("_"))
      tag.li(link_to(title, url), class: css_class, data: { scroll_into_view: })
    end

    private
    attr_reader :selected_section
  end
end
