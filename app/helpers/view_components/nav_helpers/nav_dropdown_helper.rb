module ViewComponents
  module NavHelpers
    module NavDropdownHelper
      def nav_dropdown(submenu, offset)
        tag.div class: 'nav-element-dropdown', style: "--dropdown-offset: -#{offset}px;", role: 'menu' do
          tag.ul do
            submenu.inject(''.html_safe) do |content, tag_info|
              content << tag.li(
                conditional_link(tag_info[:path]) do
                  nav_dropdown_element(tag_info[:title], tag_info[:description], tag_info[:icon])
                end <<
                nav_dropdown_view(tag_info[:content].(tag, self))
              )
            end
          end
        end
      end

      def nav_dropdown_element(title, description, icon)
        tag.div(class: "nav-dropdown-element", role: 'menuitem') do
          graphical_icon(icon) <<
            tag.div do
              content = tag.h6(title)
              content << tag.p(description) unless description.nil?
              content
            end
        end
      end

      def nav_dropdown_view(element)
        tag.div(class: 'nav-dropdown-view') do
          element
        end
      end
    end
  end
end
