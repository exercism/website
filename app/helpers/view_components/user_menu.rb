module ViewComponents
  class UserMenu < ViewComponent
    def to_s
      ReactComponents::Dropdowns::Dropdown.new(menu_button: menu_button, menu_items: menu_items)
    end

    private
    def menu_button
      {
        label: "Button to open the profile menu",
        id: "profile-menu",
        html: tag.div(class: "user-menu") do
          rounded_bg_img(
            "https://avatars3.githubusercontent.com/u/135246?s=460",
            "#{current_user.name}'s uploaded avatar"
          ) +
            icon("more-vertical", "Profile Menu")
        end
      }
    end

    def menu_items
      [
        { html: "My Journey" },
        { html: "Profile" },
        { html: "Settings" },
        { html: "Sign out" }
      ]
    end
  end
end
