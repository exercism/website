module ViewComponents
  module Localization
    class Header < ViewComponent
      def to_s
        tag.nav(class: 'c-mentor-header') do
          tag.div(class: 'lg-container container') do
            top + bottom
          end
        end
      end

      def top
        tag.nav(class: "top") do
          tag.div(class: "title") do
            graphical_icon(:translate, hex: true) +
              tag.span("Localization")
          end + stats
        end
      end

      def bottom
        tag.nav(class: "bottom") do
          tag.div(safe_join(tabs), class: 'tabs') +
            link_to(Exercism::Routes.docs_section_path(:mentoring), class: "c-tab-2 guides") do
              graphical_icon(:guides) + tag.span("Translation Guides")
            end
        end
      end

      def stats
        tag.div(class: "stats") do
          tag.div("77 languages", class: "stat")
        end
      end

      def tabs = [originals_tab]

      def originals_tab
        tag.div(class: "c-tab-2 selected") do
          graphical_icon(:overview) +
            tag.span("Originals")
        end
      end
    end
  end
end
