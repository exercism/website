module ViewComponents
  class UserMenu < ViewComponent
    def to_s
      ReactComponents::Dropdowns::PrerenderedDropdown.new(menu_button_html: menu_button_html,
                                                          menu_items_html: menu_items_html)
    end

    private
    def menu_button_html
      tag.div(class: "user-menu") do
        rounded_bg_img(
          "https://avatars3.githubusercontent.com/u/135246?s=460",
          "#{current_user.name}'s uploaded avatar"
        ) +
          icon("more-vertical", "Profile Menu")
      end
    end

    def menu_items_html
      tag.nav do
        tag.ul do
          # TODO: add the appropriate links once we have routes for them
          tag.li("My Journey") +
            tag.li("Profile") +
            tag.li("Settings") +
            tag.li("Sign out")
        end
      end
    end
  end
end
