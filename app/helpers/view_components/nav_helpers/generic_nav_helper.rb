module ViewComponents
  module NavHelpers
    module GenericNavHelper
      def generic_nav(nav_title, submenu: nil, view: nil, path: nil, offset: 0, has_view: true)
        tag.li class: 'nav-element' do
          content = conditional_link(path) do
            tag.span(nav_title, tabindex: path.nil? ? 0 : -1, role: 'none',
              class: "nav-element-label #{path.nil? ? 'nav-element-focusable' : ''}")
          end
          if view.present?
            content << tag.div(nav_dropdown_view(view), class: 'nav-element-dropdown')
          elsif submenu.present?
            content << nav_dropdown(submenu, offset, has_view) << css_arrow
          end
          content << css_arrow if view.present? || submenu.present?
          content
        end
      end

      def conditional_link(path = nil)
        content = yield

        if path.nil?
          content
        else
          link_to(content, path, tabindex: 0, role: 'none', class: 'nav-element-link nav-element-focusable')
        end
      end

      def css_arrow
        tag.div class: 'arrow'
      end
    end
  end
end
