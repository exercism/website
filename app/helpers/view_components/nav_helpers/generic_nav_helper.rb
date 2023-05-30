module ViewComponents
  module NavHelpers
    module GenericNavHelper
      def generic_nav(nav_title, submenu: nil, view: nil, path: nil, offset: 0, has_view: false, css_class: nil)
        tag.li class: "nav-element #{css_class}" do
          content = conditional_link(path) do
            tag.span(nav_title, tabindex: path.nil? ? 0 : -1, role: 'none',
              class: "nav-element-label #{path.nil? ? 'nav-element-focusable' : ''}")
          end
          if view.present?
            content << tag.div(nav_dropdown_view(view), class: 'nav-element-dropdown only-view',
              style: "--dropdown-offset: -#{offset}px;")
          elsif submenu.present?
            content << nav_dropdown(submenu, offset, has_view)
          end
          content << css_arrow if view.present? || submenu.present?
          content
        end
      end

      def conditional_link(path = nil, external: false)
        content = yield

        if path.nil?
          content
        else
          opts = {
            tabindex: 0, role: 'none', class: 'nav-element-link nav-element-focusable'
          }
          opts.merge!(target: "_blank", rel: 'noreferrer') if external # rubocop:disable Performance/RedundantMerge

          link_to(content, path, **opts)
        end
      end

      def css_arrow
        tag.div class: 'arrow'
      end
    end
  end
end
