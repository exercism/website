module ViewComponents
  class DocsMainNav < ViewComponent
    extend Mandate::Memoize

    def initialize(selected_section = nil)
      super()

      @selected_section = selected_section
    end

    def to_s
      tag.div(class: "c-docs-nav") do
        tag.div(lhs + rhs, class: "lg-container container")
      end
    end

    def lhs
      tag.nav(class: 'lhs') do
        tag.ul do
          safe_join(
            [
              tag.li(class: !selected_section ? "selected" : nil) do
                link_to Exercism::Routes.docs_url do
                  icon :home, "Docs home"
                end
              end,

              li_link("Using Exercism", :using),
              li_link("Building Exercism", :building),
              li_link("Mentoring", :mentoring),
              li_link("Community", :community),
              li_link("Not-for-profit", :organisation),
              li_link("Track-specific", :tracks)
            ]
          )
        end
      end
    end

    def rhs
      tag.nav do
        tag.ul do
          safe_join(
            [
              tag.li(class: 'api') { link_to "🎉  Exercism API", "#" },
              tag.li { link_to "Support", "#" }
            ]
          )
        end
      end
    end

    def li_link(title, section)
      css_class = section == selected_section ? "selected" : nil
      url = Exercism::Routes.doc_section_path(section)
      tag.li(link_to(title, url), class: css_class)
    end

    private
    attr_reader :selected_section
  end
end
