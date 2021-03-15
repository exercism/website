module ViewComponents
  class DocsMainNav < ViewComponent
    extend Mandate::Memoize

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
              tag.li do
                link_to Exercism::Routes.docs_url do
                  icon :home, "Docs home"
                end
              end,

              tag.li { link_to "Using Exercism", "#" },
              tag.li(class: 'selected') { link_to "Contributing", "#" },
              tag.li { link_to "Maintaining", "#" },
              tag.li { link_to "Organisation", "#" },
              tag.li { link_to "Misc", "#" },
              tag.li { link_to "Track-specific", "#" }
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
  end
end
