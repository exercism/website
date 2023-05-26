module ViewComponents
  module NavHelpers
    module NavDropdownHelper
      def nav_dropdown(submenu, offset, has_view)
        tag.div class: "nav-element-dropdown #{has_view ? 'has-view' : 'has-no-view'}", style: "--dropdown-offset: -#{offset}px;",
          role: 'menu' do
          tag.ul do
            submenu.inject(''.html_safe) do |content, element|
              view = nav_dropdown_view(element[:view]) if has_view
              icon_filter = element[:icon_filter] || 'none'

              content << tag.li(
                conditional_link(element[:path]) do
                  nav_dropdown_element(element[:title], element[:description], element[:icon], icon_filter)
                end << view
              )
            end
          end
        end
      end

      def nav_dropdown_element(title, description, icon, icon_filter)
        tag.div(class: "nav-dropdown-element", role: 'menuitem') do
          graphical_icon(icon, css_class: "filter-#{icon_filter}") <<
            tag.div(class: 'overflow-hidden') do
              content = tag.h6(title)
              content << tag.p(description) unless description.nil?
              content
            end
        end
      end

      def nav_dropdown_view(view)
        tag.div(class: 'nav-dropdown-view') do
          tag.div(class: 'nav-dropdown-view-content') do
            render(template: "layouts/nav/#{view}")
          end
        end
      end
    end
  end
end
