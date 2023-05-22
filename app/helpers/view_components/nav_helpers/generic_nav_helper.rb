module ViewComponents
  module NavHelpers
    module GenericNavHelper
      def generic_nav(nav_title, submenu, path = nil, offset = 0)
        tag.li class: 'nav-element', role: 'none' do
          content = conditional_link(path) do
            tag.span(nav_title, tabindex: 0)
          end
          content << nav_dropdown(submenu, offset) << css_arrow if submenu.present?
          content
        end
      end

      def conditional_link(path = nil)
        content = yield

        if path.nil?
          content
        else
          link_to(content, path, tabindex: -1)

        end
      end

      def css_arrow
        tag.div class: 'arrow'
      end
    end
  end
end
