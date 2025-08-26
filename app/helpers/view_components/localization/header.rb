module ViewComponents
  module Localization
    class Header < ViewComponent
      delegate :controller_name, to: :view_context

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

      def tabs = [overview_tab, originals_tab]

      def overview_tab
        selected = controller_name == "originals" ? "" : " selected"
        tag.div(class: "c-tab-2 #{selected}") do
          graphical_icon(:overview) +
            tag.span("Overview")
        end
      end

      def originals_tab
        selected = controller_name == "originals" ? "selected" : ""
        tag.div(class: "c-tab-2 #{selected}") do
          graphical_icon(:overview) +
            tag.span("Translations")
        end
      end
    end
  end
end
