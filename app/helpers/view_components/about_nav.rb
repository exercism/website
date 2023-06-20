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
            li_link("Supporting Orgs", :organisation_supporters)
            # li_link("Community", :community),
            # li_link("Not-for-profit", :organisation),
            # li_link("Track-specific", :tracks)
          ]
        )
      end
    end

    def li_link(title, section = nil)
      css_class = section == selected_section ? "selected" : nil
      id = section == selected_section ? "selected-item" : nil
      url = Exercism::Routes.send([section, "about_path"].compact.join("_"))
      tag.li(link_to(title, url), class: css_class, id:)
    end

    private
    attr_reader :selected_section
  end
end
